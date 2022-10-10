//
//  AudioVisualizationView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI
import DSWaveformImage


struct AudioVisualizationView: View {
    @EnvironmentObject var audioRecorderViewModel: AudioRecorderViewModel
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .white, width: 3, spacing: 3)),
        position: .middle
    )
    
    var body: some View {
        WaveformLiveCanvas(
            samples: $audioRecorderViewModel.samples,
            configuration: $liveConfiguration,
            shouldDrawSilencePadding: .constant(true)
        )
    }
}
