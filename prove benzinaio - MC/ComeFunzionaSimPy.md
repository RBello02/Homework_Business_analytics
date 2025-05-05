## **Come funziona Ciw (libreria Python)?**
Il source code può essere trovato nella relativa [repository GitHub](https://github.com/CiwPython/Ciw).

> Ciw uses the event scheduling approach [SR14] , similar to the three phase approach. In the event scheduling approach, three types of event take place: A Events move the clock forward, B Events are prescheduled events, and C Events are events that arise because a B Event has happened.     
Here A-events correspond to moving the clock forward to the next B-event. B-events correspond to either an external arrival, a customer finishing service, or a server shift change. C-events correspond to a customer starting service, customer being released from a node, and being blocked or unblocked.

In event scheduling the following process occurs: 
1. Initialise the simulation
2. A Phase: move the clock to the next scheduled event
3. Take a B Event scheduled for now, carry out the event
4. Carry out all C Events that arose due to the event carried out in (3.)
5. Repeat (3.) - (4.) until all B Event scheduled for that date have been carried out
6. Repeat (2.) - (5.) until a terminating criteria has been satisfied


Questa libreria permette di simulare ogni network rappresentabile mediante rete di Jacskon. Questa la si va a definire con un apposito comando, `create_network()` che prende in input i rate di arrivo esterni alle code, i rate di distribuzione, numeri di server, eventuale indicazione se le code sono a capacità finita o meno ed altre info.  
Queste info vengono codificate per creare le apposite istanze delle classi `ServiceCentre`, `CustomerClass` e `Network`.




## **Struttura di base semplificate**
Moduli che dovrebbero essere presenti anche nella nostra libreria:

- **simulation**: contiene il cuore del motore di simulazione; estrae ed esegue eventi dall'event list.
- **network**: definisce la struttura del sistema di code e i parametri per ogni nodo.
- **node**: gestisce le code locali, l'arrivo dei clienti e l'assegnazione ai server. Ad ogni nodo è associato una coda e un gruppo di server
- **server**: rappresenta un singolo server che può essere libero o occupato.
- **customer**: rappresenta un cliente nel sistema, con dati come tempo di arrivo, inizio/fine servizio, percorso.
- **events**: implementa la lista degli eventi come una priority queue (es. con `heapq`), e definisce gli eventi base.
- **distributions**: fornisce un'interfaccia unificata per le distribuzioni casuali usate nel sistema.
- **utils**: include funzioni varie come generazione ID univoci, gestione del seed random, logging, ecc.


Proposta di ChatGpt:

```
# simulation.py
import heapq
from queue_sim.events import Event
from queue_sim.customer import Customer

class Simulation:
    def __init__(self, network):
        self.network = network
        self.event_queue = []
        self.current_time = 0.0
        self.customers = []

    def schedule_event(self, event):
        heapq.heappush(self.event_queue, event)

    def run(self, until):
        # Pianifica il primo arrivo per ogni nodo
        for node in self.network.nodes:
            node.schedule_initial_arrival(self)

        while self.event_queue and self.current_time < until:
            event = heapq.heappop(self.event_queue)
            self.current_time = event.time
            event.process(self)

    def get_customers(self):
        return self.customers

    def record_customer(self, customer):
        self.customers.append(customer)
```

```
# network.py
from queue_sim.node import Node

class Network:
    def __init__(self, arrival_distributions, service_distributions, number_of_servers):
        self.nodes = []
        for i in range(len(arrival_distributions)):
            node = Node(
                id=i,
                arrival_distribution=arrival_distributions[i],
                service_distribution=service_distributions[i],
                num_servers=number_of_servers[i]
            )
            self.nodes.append(node)
```

```
# node.py
from queue_sim.server import Server
from queue_sim.customer import Customer
from queue_sim.events import ArrivalEvent

class Node:
    def __init__(self, id, arrival_distribution, service_distribution, num_servers):
        self.id = id
        self.arrival_distribution = arrival_distribution
        self.service_distribution = service_distribution
        self.queue = []
        self.servers = [Server() for _ in range(num_servers)]

    def schedule_initial_arrival(self, sim):
        arrival_time = self.arrival_distribution.sample()
        sim.schedule_event(ArrivalEvent(time=arrival_time, node=self))

    def add_customer(self, customer, sim):
        # Cerca server libero
        for server in self.servers:
            if not server.busy:
                server.start_service(customer, sim, self)
                return
        # Altrimenti accoda
        self.queue.append(customer)

    def finish_service(self, customer, sim, server):
        server.finish()
        sim.record_customer(customer)

        # Se c'è qualcuno in coda, servilo
        if self.queue:
            next_customer = self.queue.pop(0)
            server.start_service(next_customer, sim, self)

```

```
# customer.py
import itertools

class Customer:
    id_iter = itertools.count()

    def __init__(self, arrival_time):
        self.id = next(Customer.id_iter)
        self.arrival_time = arrival_time
        self.service_start = None
        self.service_end = None

    def waiting_time(self):
        return self.service_start - self.arrival_time if self.service_start else 0

    def service_time(self):
        return self.service_end - self.service_start if self.service_end else 0

```

```
# server.py
from queue_sim.events import DepartureEvent

class Server:
    def __init__(self):
        self.busy = False
        self.customer = None

    def start_service(self, customer, sim, node):
        self.busy = True
        self.customer = customer
        customer.service_start = sim.current_time
        service_time = node.service_distribution.sample()
        customer.service_end = sim.current_time + service_time
        sim.schedule_event(DepartureEvent(time=customer.service_end, node=node, server=self, customer=customer))

    def finish(self):
        self.busy = False
        self.customer = None

```

```
# events.py
from queue_sim.customer import Customer

class Event:
    def __init__(self, time):
        self.time = time

    def __lt__(self, other):  # Per heapq
        return self.time < other.time

    def process(self, sim):
        pass

class ArrivalEvent(Event):
    def __init__(self, time, node):
        super().__init__(time)
        self.node = node

    def process(self, sim):
        customer = Customer(arrival_time=self.time)
        self.node.add_customer(customer, sim)
        # Pianifica prossimo arrivo
        next_arrival = self.time + self.node.arrival_distribution.sample()
        sim.schedule_event(ArrivalEvent(time=next_arrival, node=self.node))

class DepartureEvent(Event):
    def __init__(self, time, node, server, customer):
        super().__init__(time)
        self.node = node
        self.server = server
        self.customer = customer

    def process(self, sim):
        self.node.finish_service(self.customer, sim, self.server)

```


```
# distributions.py
import random

class Exponential:
    def __init__(self, rate):
        self.rate = rate

    def sample(self):
        return random.expovariate(self.rate)

class Deterministic:
    def __init__(self, value):
        self.value = value

    def sample(self):
        return self.value

```

```
# utils.py
def set_seed(seed):
    import random
    random.seed(seed)

```


## **QUESTIONI APERTE**
- La nostra libreria dev'essere in Python
- In questa implementazione manca tutto l'aspetto del calcolo delle statistiche che va in qualche modo integrato
- Alcuni metodi vanno ampliati
- Aggiungerei la possibilità di avere code FIFO o LIFO o DI PRIORITà in base alla decisione dell'utilizzatore