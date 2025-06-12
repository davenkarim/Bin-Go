//
//  ImagePicker.swift
//  BinGo
//
//  Created by Daven Karim on 12/06/25.
//

import SwiftUI
import UIKit // Diperlukan untuk UIImagePickerController

struct ImagePicker: UIViewControllerRepresentable {
    // Binding untuk menyimpan gambar yang dipilih kembali ke tampilan induk
    @Binding var selectedImage: UIImage?
    // Closure untuk memberi tahu tampilan induk bahwa gambar telah dipilih
    var onImagePicked: (UIImage) -> Void

    // Mengkonfigurasi dan mengembalikan UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // Menetapkan koordinator sebagai delegasi
        picker.sourceType = .photoLibrary // Mengatur sumber ke galeri foto
        return picker
    }

    // Metode ini dipanggil saat SwiftUI memperbarui tampilan
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Tidak ada yang perlu diperbarui dalam kasus sederhana ini
    }

    // Membuat koordinator untuk bertindak sebagai delegasi UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Kelas Coordinator untuk menangani delegasi UIImagePickerController
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker // Referensi ke struct ImagePicker induk

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Dipanggil saat pengguna selesai memilih gambar
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Mendapatkan gambar asli dari informasi
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // Memperbarui binding gambar yang dipilih
                parent.onImagePicked(image) // Memanggil callback
            }
            picker.dismiss(animated: true) // Menutup image picker
        }

        // Dipanggil saat pengguna membatalkan pemilihan gambar
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) // Menutup image picker
        }
    }
}
