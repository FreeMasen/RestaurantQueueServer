# RestaurantQueueServer
========================
#### Reservation
simple object that will be stored to track people entering the resteraunt
``` swift
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
this uses the [Zewo](https://github.com/Zewo/Zewo) HTTPServer module to respond to requests
on port 8080 (the default)

##### Get
There are two Get methods, one to confirm that the server is up and running
the other returns our Reservations as plain text seperated by commas
``` swift 
route.get("/api") { request in 
		print(request)
		return Response(body: "connected")
	}
route.get("/api/RestaurantQueue") { request in 
	let valueForReturn = reservationsAsString()
	print("getRequest: \(request) \(NSDate())")
	print(valueForReturn)
	return Response(body: valueForReturn)
}
```

##### Post
this adds a new Reservation and assigns the id to the number of seconds
since 1970
``` swift
route.post("/api/RestaurantQueue/:name/:size/") { request in
	print("post request: \(request) \(NSDate())")
	guard let name = request.pathParameters["name"],
	       	size = request.pathParameters["size"]	else {
		return Response(body: "error with request")
	}
	let id = NSDate().timeIntervalSince1970

	let newReservation = Reservation(id: Int(id), name: name, size: Int(size)!, arrivalTime: "\(NSDate())", isReady: false)
	reservations.append(newReservation)
	storeReservations()
	return Response(body: reservationsAsString())
}
```
##### Put
this updates an existing Reservation by capturing the ":id" portion of the url
and updating the object that shares that id.  It then returns the full list
to the caller
``` swift 
route.put("/api/RestaurantQueue/seat/:id") { request in
	print("put request: \(request) \(NSDate())")
	guard let id = request.pathParameters["id"], resId = Int(id) else {
		return Response(body: "error with ID")
	}
	for reservation in reservations {
		if reservation.id == resId {
			reservation.isReady = true
			storeReservations()
			return Response(body: reservationsAsString())
		}
	}
	return Response(body: "no reservation found")
}
```

##### Delete
this removes an existing Reservation by capturing the ":id" portion of the url
and removing the object that shares that id.  It then returns the full list
to the caller
``` swift 
route.delete("/api/RestaurantQueue/remove/:id") { request in
	print("delete request: \(request) \(NSDate())")
	guard let id = request.pathParameters["id"],
       		resId = Int(id)	else {
		return Response(body: "error with ID")
	}
	reservations = reservations.filter { $0.id != resId }	
	storeReservations()
	return Response(body: reservationsAsString())
}
```

#### Data Storage
Reservations are stored in a text file called reservations.txt in a CSV format
each element is tagged with its variable name followed by a : to make things a little easier
on the client side

I would like to convert this the JSON but right now server side swift does not have a ton of 
great options for this

this method is used to convert the an array of Reservation objects into a CSV String
``` swift
func reservationsAsString() -> String {
	var string = ""
	for res in reservations {
		string += "id:\(res.id), "
		string += "name:\(res.name), "
		string += "size:\(res.size), "
		string += "time:\(res.arrivalTime), "
		string += "isReady:\(res.isReady)\n"
	}
	return string
}
```

This method leverages the Zewo module File to write a string as data to a text file
``` swift
func storeReservations() {
	do {
		let wrkDir = try File.workingDirectory()
		let file = try File(path: "\(wrkDir)/Resources/reservations.txt", mode: .ReadWrite)
		let data = Data(stringLiteral: reservationsAsString())
		try file.write(data)
		file.close()
	} catch {
		print("failed to write reservations to txt: \(error)")
	}
}
```
these methods are used to retrieve the contents of our file
``` swift
func readStoredReservations() {
	do {
		let wrkDir = try File.workingDirectory()
		let file = try File(path: "\(wrkDir)/Resources/reservations.txt", mode: .ReadWrite)
		let contents = try file.read()
		let contentsString = try String(data: contents)
		processStoredReservations(contentsString)
	} catch {
		print("read error: \(error)")
	}
}

func processStoredReservations(stringFromFile: String) -> [Reservation] {
	var reservations = [Reservation]() 
	let longLines = stringFromFile.split("\n")
	let lines = longLines.map { $0.trim() }
	let splitLines = lines.map { $0.split(",") }
	print("splitLines: \(splitLines)")
	for splitString in splitLines {
		var id: Int?
		var name: String?
		var size: Int?
		var timeArrived: String?
		var ready: Bool?
		for entry in splitString {
			print("entry: \(entry)")
			if entry.containsString("id") {
				let idString = entry.componentsSeparatedByString(":")[1]
				id = Int(idString)
			} else if entry.containsString("name"){
				let nameString = entry.componentsSeparatedByString(":")[1]
				name = nameString
			} else if entry.containsString("size") {
				let sizeString = entry.componentsSeparatedByString(":")[1]
				size = Int(sizeString)
			} else if entry.containsString("time") {
				let timeString = entry.componentsSeparatedByString(":")
				print (timeString)
				timeArrived = timeString[1]
			} else if entry.containsString("isReady") {
				ready = entry.containsString("true")
			} else {
				print("not found")
			}

			if let idBang = id, nameBang = name, sizeBang = size, 
				timeArrivedBang = timeArrived, readyBang = ready {
					let newRes = Reservation(id: idBang, name: nameBang, size: sizeBang, arrivalTime: timeArrivedBang, isReady: readyBang)
			      	 	print("added \(newRes)to reservations")
					reservations.append(newRes)
		  	    	 	id = nil; name = nil; size = nil; timeArrived = nil; ready = nil
			}	       
		}		
	}
	return reservations
}
```
