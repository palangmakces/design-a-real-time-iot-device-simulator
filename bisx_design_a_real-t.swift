import Foundation
import CoreBluetooth

// IoT Device Simulator Class
class IoTDeviceSimulator {
    var deviceId: String
    var deviceType: String
    var sensorData: [String: Double]
    var btPeripheral: CBPeripheralManager!
    
    init(deviceId: String, deviceType: String, sensorData: [String: Double]) {
        self.deviceId = deviceId
        self.deviceType = deviceType
        self.sensorData = sensorData
        self.btPeripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising() {
        let advertisementData = [CBAdvertisementDataLocalNameKey: "IoT Device Simulator"]
        btPeripheral.startAdvertising(advertisementData)
    }
    
    func updateSensorData(_ newData: [String: Double]) {
        sensorData.merge(newData, uniquingKeysWith: { _, new in new })
        sendSensorDataToCentral()
    }
    
    private func sendSensorDataToCentral() {
        let data = try! JSONEncoder().encode(sensorData)
        btPeripheral.updateValue(data, for: CBMutableCharacteristic(uuid: CBUUID(string: " SensorData"), properties: [.read], value: nil, permissions: [.readable]))
    }
}

// IoT Device Simulator Delegate
extension IoTDeviceSimulator: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            startAdvertising()
        default:
            print("Peripheral manager state: \(peripheral.state)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Error adding service: \(error)")
        }
    }
}

// IoT Device Simulator Example
let deviceSimulator = IoTDeviceSimulator(deviceId: "device-001", deviceType: "Temperature Sensor", sensorData: ["temperature": 24.5, "humidity": 60.0])

deviceSimulator.startAdvertising()

// Simulate sensor data updates
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    deviceSimulator.updateSensorData(["temperature": Double.random(in: 23.0...25.0), "humidity": Double.random(in: 55.0...65.0)])
}