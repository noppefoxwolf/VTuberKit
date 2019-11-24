//
//  MicTracking.swift
//  VTuberKit
//
//  Created by Tomoya Hirano on 2019/11/25.
//

import UIKit
import AVFoundation

public protocol MicTrackingDelegate: AnyObject {
    func micTracking(_ micTracking: MicTracking, didUpdate volume: Float)
}

public final class MicTracking: NSObject {
    private let queue: DispatchQueue = .init(label: "com.VtuberKit.micTracking", qos: .background, attributes: .init())
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.addInput(input)
        session.addOutput(output)
        return session
    }()
    private let device: AVCaptureDevice = .default(for: .audio)!
    private lazy var input: AVCaptureDeviceInput = try! .init(device: device)
    private lazy var output: AVCaptureOutput = {
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)
        return output
    }()
    public weak var delegate: MicTrackingDelegate?
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
}

extension MicTracking: AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let audioChannel = connection.audioChannels.first else { return }
        delegate?.micTracking(self, didUpdate: 1.0 - (-audioChannel.averagePowerLevel) / 50.0)
    }
}
