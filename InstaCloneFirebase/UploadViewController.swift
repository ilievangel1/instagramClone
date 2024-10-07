//
//  UploadViewController.swift
//  InstaCloneFirebase
//
//  Created by Angel Iliev on 28.11.23.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func choseImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func uploadClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageRefference = storage.reference()
        let mediaFolder = storageRefference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageRefference = mediaFolder.child("\(uuid).jpg")
            imageRefference.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    imageRefference.downloadURL { (url, error) in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            // Database
                            
                            let firestoreDatabase = Firestore.firestore()
//                            var firestoreReference: DocumentReference? = nil
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email, "postComment" : self.commentText.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0] as [String : Any]
                            
                            // Add a new document with a generated ID
                            Task {
                                do {
                                  let ref = try await firestoreDatabase.collection("users").addDocument(data: firestorePost)
                                  print("Document added with ID: \(ref.documentID)")
                                  self.imageView.image = UIImage(named: "selectImage.png")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                } catch {
                                    self.makeAlert(titleInput: "Error!", messageInput: error.localizedDescription ?? "Error")
                                }
                            }
                            
                            
//                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
//                                if error != nil {
//                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
//                                }
//                            })
                        }
                    }
                }
            }
        }
        
    }
    
}
