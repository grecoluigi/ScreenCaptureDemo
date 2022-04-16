//
//  ViewController.swift
//  ScreenCaptureDemo
//
//  Created by Luigi Greco on 12/04/22.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureFileOutputRecordingDelegate {
    
    var screenSession = AVCaptureSession()
    var cameraSession = AVCaptureSession()
    var input = AVCaptureScreenInput()
    var output = AVCaptureMovieFileOutput()
    var screenCaptureOutputUrl : URL? = nil
    var cameraOutputUrl : URL? = nil
    var isRecording = false
    var shouldRecordScreen = Bool()
    var shouldRecordWebcam = Bool()
    var shouldRecordMicrophone = Bool()
    var screenCaptureURL : URL? = nil
    var previewLayer : AVCaptureVideoPreviewLayer?

    @IBOutlet weak var screenCaptureOutputUrlTextField: NSTextFieldCell!
    @IBOutlet weak var webcamOutputUrlTextField: NSTextField!
    @IBOutlet weak var recordScreenCheck: NSButton!
    @IBOutlet weak var recordWebcamCheck: NSButton!
    @IBOutlet weak var recordMicrophoneCheck: NSButton!
    @IBOutlet weak var previewView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if recordScreenCheck.state == .on {
            shouldRecordScreen = true
        }
        if recordWebcamCheck.state == .on {
            shouldRecordWebcam = true
        }
        if recordMicrophoneCheck.state == .on {
            shouldRecordMicrophone = true
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func createTempFileURL() -> URL {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                           FileManager.SearchPathDomainMask.userDomainMask, true).last
            let pathURL = NSURL.fileURL(withPath: path!)
            let fileURL = pathURL.appendingPathComponent("rec-\(NSDate.timeIntervalSinceReferenceDate).mov")
            return fileURL
        }

    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        screenCaptureOutputUrlTextField.stringValue = screenCaptureURL?.absoluteString ?? ""
        webcamOutputUrlTextField.stringValue = cameraOutputUrl?.absoluteString  ?? ""
        output.stopRecording()
    }
    
    @IBAction func startStopCaptureButtonPressed(_ sender: NSButton) {
        if !isRecording {
            isRecording = true
            if shouldRecordScreen {
                screenSession = AVCaptureSession.init()
                screenSession.beginConfiguration()
                screenSession.sessionPreset = AVCaptureSession.Preset.high
                input = AVCaptureScreenInput(displayID: CGMainDisplayID())!
                screenSession.addInput(input)
                output = AVCaptureMovieFileOutput()
                screenSession.addOutput(self.output)
                screenSession.commitConfiguration()
                screenSession.startRunning()
                screenCaptureURL = createTempFileURL()
                output.startRecording(to: screenCaptureURL!, recordingDelegate: self)
            }
            if (shouldRecordWebcam || shouldRecordMicrophone) {
                cameraSession = AVCaptureSession.init()
                cameraSession.beginConfiguration()
                cameraSession.sessionPreset = AVCaptureSession.Preset.high
                if shouldRecordWebcam {
                    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
                    guard
                        let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
                        cameraSession.canAddInput(videoDeviceInput)
                    else { return }
                    cameraSession.addInput(videoDeviceInput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
                    previewLayer!.bounds = previewView.bounds
                    previewLayer!.position = CGPoint(x: previewView.bounds.midX, y: previewView.bounds.midY)
                    previewLayer!.videoGravity = .resizeAspect
                    previewLayer!.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                    previewView.layer?.addSublayer(previewLayer!)
                }
                if shouldRecordMicrophone {
                    let audioDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)
                    guard
                        let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice!),
                        cameraSession.canAddInput(audioDeviceInput)
                    else { return }
                    cameraSession.addInput(audioDeviceInput)
                }
                output = AVCaptureMovieFileOutput()
                cameraSession.addOutput(self.output)
                cameraSession.commitConfiguration()
                cameraSession.startRunning()
                cameraOutputUrl = createTempFileURL()
                output.startRecording(to: cameraOutputUrl!, recordingDelegate: self)
            }
            sender.title = "Stop capture"
        } else {
            isRecording = false
            sender.title = "Start capture"
            if self.cameraSession.isRunning {
                self.cameraSession.stopRunning()
            }
            if self.screenSession.isRunning {
                self.screenSession.stopRunning()
            }
        }
    }
    
    func showInFinder(url: URL?) {
        NSWorkspace.shared.selectFile(url?.relativePath, inFileViewerRootedAtPath: "")
    }
    @IBAction func showScreenCaptureFileInFinder(_ sender: NSButton) {
        showInFinder(url: screenCaptureURL)
    }
    
    
    @IBAction func showCameraFileInFinder(_ sender: Any) {
        showInFinder(url: cameraOutputUrl)
    }
    
    @IBAction func recordScreenCheckChanged(_ sender: NSButton) {
        if sender.state == .on {
            shouldRecordScreen = true
        } else {
            shouldRecordScreen = false
        }
    }
    
    @IBAction func recordWebcamCheckChanged(_ sender: NSButton) {
        if sender.state == .on {
            shouldRecordWebcam = true
        } else {
            shouldRecordWebcam = false
        }
    }
    
    @IBAction func recordMicrophoneCheckChanged(_ sender: NSButton) {
        if sender.state == .on {
            shouldRecordMicrophone = true
        } else {
            shouldRecordMicrophone = false
        }
    }
    
}
