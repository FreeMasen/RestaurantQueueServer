# RestaurantQueueServer
========================
#### Reservation
simple object that will be stored to track people entering the resteraunt
```
class Reservation {
	var id: Int
	var name: String
	var size: Int
	var arrivalTime: String
	var isReady: Bool

	init(id: Int, name: String, size: Int, arrivalTime: String, isReady: Bool) {
		self.id = id
		self.name = name
		self.size = size
		self.arrivalTime = arrivalTime
		self.isReady = isReady
	}
}
```

#### Router
this uses the [https://github.com/Zewo/Zewo]Zewo HTTPServer module to respond to requests
on port 8080 (the default)

##### Get
This returns the list of stored objects in a CSV format

##### Post
this adds a new Reservation

##### Put
this updates an existing Reservation

##### Delete
this removes an existing Reservation


#### Data Storage
Reservations are stored in a text file called reservations.txt in a CSV format
each element is tagged with its variable name followed by a : to make things a little easier
on the client side

I would like to convert this the JSON but right now server side swift does not have a ton of 
great options for this

