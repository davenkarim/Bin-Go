//
//  ContentView.swift
//  BinGo
//
//  Created by Daven Karim on 12/06/25.
//

import SwiftUI
import CoreML // buat interaksi sama model (.mlmodel)
import Vision // buat proses gambar sama Core ML

struct ContentView: View {
    // state variabel buat nyimpen gambar yang dipilih user
    @State private var selectedImage: UIImage?
    // state variabel buat nampilin hasil klasifikasi
    @State private var classificationResult: String = "Pilih gambar untuk klasifikasi sampah"
    // State variable untuk mengontrol tampilan ImagePicker
    @State private var isShowingImagePicker: Bool = false
    // State variable untuk menampilkan pesan loading saat klasifikasi sedang berlangsung
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                // nampilin gambar
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .cornerRadius(15) // Sudut membulat
                        .shadow(radius: 10) // Efek bayangan
                } else {
                    // Placeholder jika belum ada gambar yang dipilih
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(maxWidth: 370, maxHeight: 300)
                        .cornerRadius(15)
                        .overlay(
                            Text("Tidak Ada Gambar")
                                .font(.title3)
                                .foregroundColor(.gray)
                        )
                }

                // Menampilkan hasil klasifikasi
                Text(classificationResult)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1))) // Latar belakang dengan sudut membulat
                    .padding(.horizontal)
                    .foregroundColor(.primary)

                // Indikator loading saat klasifikasi berlangsung
                if isLoading {
                    ProgressView("Menganalisis...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }

                Spacer()

                // Tombol untuk memilih gambar
                Button(action: {
                    self.isShowingImagePicker = true // Menampilkan image picker saat tombol ditekan
                }) {
                    Label("Pilih Gambar", systemImage: "photo.on.rectangle.angled")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 25)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Klasifikasi Sampah")
            // Sheet untuk menampilkan ImagePicker
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: self.$selectedImage) { image in
                    // Callback saat gambar dipilih dari ImagePicker
                    self.selectedImage = image
                    // Mulai klasifikasi setelah gambar dipilih
                    self.classifyImage(image: image)
                }
            }
            // Mengamati perubahan pada selectedImage untuk memicu klasifikasi
            // Ini adalah pendekatan alternatif jika Anda ingin klasifikasi langsung saat gambar berubah
            // .onChange(of: selectedImage) { newImage in
            //    if let newImage = newImage {
            //        classifyImage(image: newImage)
            //    }
            // }
        }
    }

    // Fungsi untuk mengklasifikasikan gambar menggunakan model Core ML
    private func classifyImage(image: UIImage) {
        // Mengatur status loading dan pesan hasil
        isLoading = true
        classificationResult = "Menganalisis..."

        guard let model = try? VNCoreMLModel(for: TrashImageClassifier().model) else {
            // Menangani error jika model tidak dapat dimuat
            classificationResult = "Error: Tidak dapat memuat model TrashImageClassifier."
            isLoading = false
            return
        }

        // Membuat permintaan Vision untuk Core ML
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // Selesai loading
            self.isLoading = false

            guard let results = request.results as? [VNClassificationObservation] else {
                // Menangani error jika hasil tidak dapat diinterpretasikan
                self.classificationResult = "Error: Tidak dapat menginterpretasikan hasil klasifikasi."
                return
            }

            // Memproses hasil klasifikasi
            // Mengambil hasil dengan kepercayaan tertinggi
            if let topResult = results.first {
                // Menampilkan label dan kepercayaan diri
                let confidence = String(format: "%.2f", topResult.confidence * 100)
                self.classificationResult = "Ini adalah: \(topResult.identifier) (Kepercayaan: \(confidence)%)"
            } else {
                self.classificationResult = "Tidak ada hasil klasifikasi yang ditemukan."
            }
        }

        // Mengubah UIImage ke CIImage untuk pemrosesan Vision
        guard let ciImage = CIImage(image: image) else {
            classificationResult = "Error: Tidak dapat mengonversi gambar ke CIImage."
            isLoading = false
            return
        }

        // Membuat handler permintaan gambar
        let handler = VNImageRequestHandler(ciImage: ciImage)

        // Melakukan permintaan klasifikasi
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                // Menangani error saat melakukan permintaan
                DispatchQueue.main.async {
                    self.classificationResult = "Error: Gagal melakukan klasifikasi: \(error.localizedDescription)"
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
