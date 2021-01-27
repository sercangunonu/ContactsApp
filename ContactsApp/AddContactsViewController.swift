//
//  AddContactsViewController.swift
//  ContactsApp
//
//  Created by Seyda Gunonu on 23.01.2021.
//

import UIKit
import CoreData

class AddContactsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextView!
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var surnameErrorLabel: UILabel!
    @IBOutlet weak var birthdateErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var noteErrorLabel: UILabel!
    
    @IBOutlet weak var phoneAreaPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenContact = ""
    var chosenContactID: UUID?
    
    let areaCodes = ["+90","+1"]
    var toggleButton: String = ""
    
    private var datePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 20
        
        selectedContact()
        errorLabelHidden()
        datePickerSelected()
        
        phoneAreaPicker.delegate = self
        phoneAreaPicker.dataSource = self
        phoneNumberTextField.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func datePickerSelected() {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale(identifier: "tr")
        datePicker?.addTarget(self, action: #selector(AddContactsViewController.dateChanged(datePicker:)), for: .valueChanged)
        birthdateTextField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        birthdateTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    //ekleme ekraninda keyboard kapatma
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func errorLabelHidden(){
        nameErrorLabel.isHidden = true
        surnameErrorLabel.isHidden = true
        birthdateErrorLabel.isHidden = true
        emailErrorLabel.isHidden = true
        phoneNumberErrorLabel.isHidden = true
        noteErrorLabel.isHidden = true
    }
    
    func createPopUp (){
        
        let popup = UIAlertController(title: "", message: "Kayıt Başarılı", preferredStyle: UIAlertController.Style.alert)
        self.present(popup, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in popup.dismiss(animated: true, completion: nil)})
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        var pickerValue = ""
        let pickerSelectedRow = phoneAreaPicker.selectedRow(inComponent: 0)
        if let value = phoneAreaPicker.delegate?.pickerView?(phoneAreaPicker, titleForRow: pickerSelectedRow, forComponent: 0){
            pickerValue = value
        }
        
        if toggleButton == "1" {
            
            if chosenContact != "" {
                if nameTextField.text!.isValidName{
                    nameErrorLabel.isHidden = true
                    nameTextField.layer.borderWidth = 0
                                
                    if surnameTextField.text!.isValidSurname{
                        surnameErrorLabel.isHidden = true
                        surnameTextField.layer.borderWidth = 0
                                        
                        if birthdateTextField.text != ""  {
                            birthdateErrorLabel.isHidden = true
                            birthdateTextField.layer.borderWidth = 0
                                                
                            if emailTextField.text!.count < 60 && emailTextField.text!.isValidEmail {
                                emailErrorLabel.isHidden = true
                                emailTextField.layer.borderWidth = 0

                                if pickerValue == "+90" && phoneNumberTextField.text!.count < 14 || pickerValue == "+1" && phoneNumberTextField.text!.count > 12{
                                    phoneNumberErrorLabel.isHidden = true
                                    phoneNumberTextField.layer.borderWidth = 0
                                    
                                    if noteTextField.text.count < 100 {
                                        noteErrorLabel.isHidden = true
                                        noteTextField.layer.borderWidth = 0
                                        
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        let context = appDelegate.persistentContainer.viewContext
                                        
                                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
                                        let idString = chosenContactID?.uuidString
                                        
                                        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                                        fetchRequest.returnsObjectsAsFaults = false
                                        
                                        do{
                                            let results = try context.fetch(fetchRequest)
                                            if results.count > 0{
                                                for result in results as! [NSManagedObject]{
                                                    
                                                    var pickerValue = ""
                                                    let pickerSelectedRow = phoneAreaPicker.selectedRow(inComponent: 0)
                                                    if let value = phoneAreaPicker.delegate?.pickerView?(phoneAreaPicker, titleForRow: pickerSelectedRow, forComponent: 0){
                                                        pickerValue = value
                                                    }
                                                    
                                                    result.setValue(nameTextField.text, forKey: "name")
                                                    result.setValue(surnameTextField.text, forKey: "surname")
                                                    result.setValue(birthdateTextField.text, forKey: "birthdate")
                                                    result.setValue(emailTextField.text, forKey: "email")
                                                    result.setValue(phoneNumberTextField.text, forKey: "phoneNumber")
                                                    result.setValue(noteTextField.text, forKey: "note")
                                                    result.setValue(UUID(), forKey: "id")
                                                    result.setValue(pickerValue, forKey: "areaPicker")
                                                    
                                                    do {
                                                       try context.save()
                                                        print("updated")
                                                    } catch {
                                                        print("update error")
                                                    }
                                                    NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                                                    
                                                    createPopUp()
                                                }
                                            }
                                        }catch{
                                            print("update error")
                                        }
                                    }else {
                                        noteErrorLabel.isHidden = false
                                        noteTextField.layer.borderWidth = 1.0
                                        noteTextField.layer.borderColor = UIColor.red.cgColor
                                    }
                                } else {
                                    phoneNumberErrorLabel.isHidden = false
                                    phoneNumberTextField.layer.borderWidth = 1.0
                                    phoneNumberTextField.layer.borderColor = UIColor.red.cgColor
                                }
                            } else {
                                emailErrorLabel.isHidden = false
                                emailTextField.layer.borderWidth = 1.0
                                emailTextField.layer.borderColor = UIColor.red.cgColor
                            }
                        } else {
                            birthdateErrorLabel.isHidden = false
                            birthdateTextField.layer.borderWidth = 1.0
                            birthdateTextField.layer.borderColor = UIColor.red.cgColor
                        }
                    }else {
                        surnameErrorLabel.isHidden = false
                        surnameTextField.layer.borderWidth = 1.0
                        surnameTextField.layer.borderColor = UIColor.red.cgColor
                    }
                }else {
                    nameErrorLabel.isHidden = false
                    nameTextField.layer.borderWidth = 1.0
                    nameTextField.layer.borderColor = UIColor.red.cgColor
                }
            }
        } else {
            if nameTextField.text!.isValidName{
                nameErrorLabel.isHidden = true
                nameTextField.layer.borderWidth = 0
                            
                if surnameTextField.text!.isValidSurname{
                    surnameErrorLabel.isHidden = true
                    surnameTextField.layer.borderWidth = 0
                                    
                    if birthdateTextField.text != ""  {
                        birthdateErrorLabel.isHidden = true
                        birthdateTextField.layer.borderWidth = 0
                                            
                        if emailTextField.text!.count < 60 && emailTextField.text!.isValidEmail {
                            emailErrorLabel.isHidden = true
                            emailTextField.layer.borderWidth = 0
                                                    
                            if phoneNumberTextField.text!.count > 12 {
                                phoneNumberErrorLabel.isHidden = true
                                phoneNumberTextField.layer.borderWidth = 0
                                
                                if noteTextField.text.count < 100 {
                                    noteErrorLabel.isHidden = true
                                    noteTextField.layer.borderWidth = 0
                                    
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    let context = appDelegate.persistentContainer.viewContext
                              
                                    let newContact = NSEntityDescription.insertNewObject(forEntityName: "Contacts", into: context)
                                    
                                    var pickerValue = ""
                                    let pickerSelectedRow = phoneAreaPicker.selectedRow(inComponent: 0)
                                    if let value = phoneAreaPicker.delegate?.pickerView?(phoneAreaPicker, titleForRow: pickerSelectedRow, forComponent: 0){
                                        pickerValue = value
                                    }
                                    
                                    newContact.setValue(nameTextField.text, forKey: "name")
                                    newContact.setValue(surnameTextField.text, forKey: "surname")
                                    newContact.setValue(birthdateTextField.text, forKey: "birthdate")
                                    newContact.setValue(emailTextField.text, forKey: "email")
                                    newContact.setValue(phoneNumberTextField.text, forKey: "phoneNumber")
                                    newContact.setValue(noteTextField.text, forKey: "note")
                                    newContact.setValue(UUID(), forKey: "id")
                                    newContact.setValue(pickerValue, forKey: "areaPicker")
                                    
                                    do {
                                       try context.save()
                                        print("saved")
                                    } catch {
                                        print("save error")
                                    }
                                    NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                                    
                                    createPopUp()
                                }else {
                                    noteErrorLabel.isHidden = false
                                    noteTextField.layer.borderWidth = 1.0
                                    noteTextField.layer.borderColor = UIColor.red.cgColor
                                }
                            } else {
                                phoneNumberErrorLabel.isHidden = false
                                phoneNumberTextField.layer.borderWidth = 1.0
                                phoneNumberTextField.layer.borderColor = UIColor.red.cgColor
                            }
                        } else {
                            emailErrorLabel.isHidden = false
                            emailTextField.layer.borderWidth = 1.0
                            emailTextField.layer.borderColor = UIColor.red.cgColor
                        }
                    } else {
                        birthdateErrorLabel.isHidden = false
                        birthdateTextField.layer.borderWidth = 1.0
                        birthdateTextField.layer.borderColor = UIColor.red.cgColor
                    }
                }else {
                    surnameErrorLabel.isHidden = false
                    surnameTextField.layer.borderWidth = 1.0
                    surnameTextField.layer.borderColor = UIColor.red.cgColor
                }
            }else {
                nameErrorLabel.isHidden = false
                nameTextField.layer.borderWidth = 1.0
                nameTextField.layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    func selectedContact(){
        if chosenContact != "" {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
            let idString = chosenContactID?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{

                        if let name = result.value(forKey: "name") as? String{
                            nameTextField.text = name
                        }
                        if let surname = result.value(forKey: "surname") as? String{
                            surnameTextField.text = surname
                        }
                        if let birthdate = result.value(forKey: "birthdate") as? String{
                            birthdateTextField.text = birthdate
                        }
                        if let email = result.value(forKey: "email") as? String{
                            emailTextField.text = email
                        }
                        if let phoneNumber = result.value(forKey: "phoneNumber") as? String{
                            phoneNumberTextField.text = phoneNumber
                        }
                        if let note = result.value(forKey: "note") as? String{
                            noteTextField.text = note
                        }
                    }
                }
            }catch{
                print("selectedContactError")
            }
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaCodes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areaCodes[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 12)
            pickerLabel?.text = areaCodes[row]
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        return pickerLabel!
    }
    func phoneFormat(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                
                index = numbers.index(after: index)
            }else {
                result.append(ch)
            }
        }
        return result
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == phoneNumberTextField) {
            
            var pickerValue = ""
            let pickerSelectedRow = phoneAreaPicker.selectedRow(inComponent: 0)
            if let value = phoneAreaPicker.delegate?.pickerView?(phoneAreaPicker, titleForRow: pickerSelectedRow, forComponent: 0){
                pickerValue = value
            }
            if pickerValue == "+90"{
                let text = textField.text
                let newString = (text as! NSString).replacingCharacters(in: range, with: string)
                textField.text = phoneFormat(with: "XXX XXX XX XX", phone: newString)
                return false
            } else if pickerValue == "+1"{
                let text = textField.text
                let newString = (text as! NSString).replacingCharacters(in: range, with: string)
                textField.text = phoneFormat(with: "XXX XXX XXX XXX XXXX", phone: newString)
                return false
            }
            return false
        }else {
            return true
        }
    }
}

extension String{
    var isValidName: Bool {
        let nameRegEx = "[A-Za-z ]{2,20}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegEx)
        
        return nameTest.evaluate(with: self)
    }
    var isValidSurname: Bool {
        let surnameRegEx = "[A-Za-z ]{2,20}"
        let surnameTest = NSPredicate(format: "SELF MATCHES %@", surnameRegEx)
        
        return surnameTest.evaluate(with: self)
    }
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
}
