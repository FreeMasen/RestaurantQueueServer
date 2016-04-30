import Foundation 

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
