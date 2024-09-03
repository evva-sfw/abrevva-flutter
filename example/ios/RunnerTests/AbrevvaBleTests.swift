import XCTest
import Quick
import Nimble
import CoreBluetooth
import AbrevvaSDK

@testable import abrevva

final class AbrevvaBleTests: QuickSpec {
    override class func spec(){
        var abrevvaBle: AbrevvaBle?
        
        beforeEach {
          abrevvaBle = AbrevvaBle()
        }
        
        describe("getManufacturerDataDict()"){
          it("should return a dictionary containing the manufacturer data"){
            for (input, expectedOutput) in getManufacturerDataDictTestVektor {
              XCTContext.runActivity(named: "getManufacturerDataDict"){ _ in
                let output = abrevvaBle!.getManufacturerDataDict(data: input)
                
                expect(output).to(equal((expectedOutput)))
              }
            }
          }
        }
        
        describe("getServiceDataDict()"){
          it("should return a dictionary containing the service data"){
            for (uuids, data, uuidOutput, dataOutput) in getServiceDataDictTestVektor {
              XCTContext.runActivity(named: "getServiceDataDict"){ _ in
                var input: [CBUUID: Data] = [:]
                var expectedOutput: [String: String] = [:]
                if (uuids.count > 0){
                  for i in 0...uuids.count - 1 {
                    input[uuids[i]] = data[i]
                    expectedOutput[uuidOutput[i]] = dataOutput[i]
                  }
                }
                
                let output = abrevvaBle!.getServiceDataDict(data: input)
                
                expect(NSDictionary(dictionary: output).isEqual(to: expectedOutput)).to(beTrue())
              }
            }
          }
        }
        
        describe("getScanResultDict()"){
          it("should return the scan Result as dictionary"){
            let peripheralMock = mock(CBPeripheral.self)
            let testUUID = UUID().uuidString
            given(peripheralMock.identifier) ~> UUID(uuidString: testUUID)
            given(peripheralMock.name) ~> "name"
            let bleDevice = BleDevice(peripheralMock)
            
            for (txPower, uuids, localName, rssi) in getScanResultDictTestVektor {
              XCTContext.runActivity(named: "getScanResultDict"){ _ in
                var advertismentData: [String: Any] = [
                  CBAdvertisementDataTxPowerLevelKey: txPower,
                  CBAdvertisementDataServiceUUIDsKey: uuids,
                ]
                if (localName != nil) {
                  advertismentData[CBAdvertisementDataLocalNameKey] = localName
                }
                
                
                let output = abrevvaBle!.getScanResultDict(bleDevice, advertismentData, rssi)
                
                var expectedOutput: [String: Any] = [
                  "device": ["deviceId": testUUID, "name": "name"] ,
                  "rssi": rssi,
                  "txPower": txPower,
                  "uuids": CBUUIDsAsStrings(uuids),
                ]
                if (localName != nil){
                  expectedOutput["localName"] = localName
                }
                expect(NSDictionary(dictionary: output).isEqual(to: expectedOutput)).to(beTrue())
              }
            }
          }
        }
      }
    }

    private func CBUUIDsAsStrings(_ array: [CBUUID]) -> String {
      var strArray: [String] = []
      array.forEach { uuid in
        strArray.append(uuid.uuidString.lowercased())
      }
        return strArray.joined(separator: ":")
    }

    private let getServiceDataDictTestVektor = [
      (
        uuids: [CBUUID(string: "ad9be5cb-e180-4fef-8253-0a7c7c9481c0"), CBUUID(string: "f2615e93-da11-40ab-8fea-532b2ae28262")],
        data: [Data([0x01, 0x02]), Data([0x03, 0x04])],
        uuidOutput:["ad9be5cb-e180-4fef-8253-0a7c7c9481c0","f2615e93-da11-40ab-8fea-532b2ae28262"],
        dataOutput: ["01 02 ", "03 04 "]
      ),
      (
        uuids: [CBUUID(string: "ef4af0f9-6e16-470f-bb44-577349ad0b31")],
        data: [Data()],
        uuidOutput:["ef4af0f9-6e16-470f-bb44-577349ad0b31"],
        dataOutput: [""]
      ),
      (
        uuids: [],
        data: [],
        uuidOutput:[],
        dataOutput: []
      ),
    ]

    private let getManufacturerDataDictTestVektor = [
      (
        input: Data(),
        expectedOutput: ["0":""]
      ),
      (
        input: Data([0x69, 0x08]),
        expectedOutput: ["2153":""]
      ),
      (
        input: Data([0x69, 0x08, 0x01, 0x02]),
        expectedOutput: ["2153":"01 02 "]
      ),
      (
        input: Data([0x69, 0x08, 0x00, 0xFF]),
        expectedOutput: ["2153":"00 ff "]
      ),
      (
        input: Data([0x69, 0x08, 0x00, 0xFF, 0xAA, 0xA2, 0x01, 0xFF]),
        expectedOutput: ["2153":"00 ff aa a2 01 ff "]
      ),
    ]

    private let getScanResultDictTestVektor = [
      (
        txPower : 1,
        uuids : [],
        localName : "name",
        rssi : 1 as NSNumber
      ),
      (
        txPower : 45,
        uuids : [CBUUID(string: UUID().uuidString), CBUUID(string: UUID().uuidString)],
        localName : nil,
        rssi : 45
      ),
      (
        txPower : 69,
        uuids : [CBUUID(string: UUID().uuidString)],
        localName : "otherName",
        rssi : 69
      )
    ]
