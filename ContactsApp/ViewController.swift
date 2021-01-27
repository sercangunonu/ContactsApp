//
//  ViewController.swift
//  ContactsApp
//
//  Created by Seyda Gunonu on 23.01.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate{

 
    @IBOutlet weak var phoneListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var addVC = AddContactsViewController.self
    var contacts: [NSManagedObject] = []

    var selectedContact = ""
    var selectedContactID : UUID?
    
    let navBarBackground = UIImage(named: "navBarBackground")
    let leftBarImage = UIImage(named: "navBarBackButtonImage")
    let searchImage = UIImage(named: "searcImage")
    let rightBarBackground = UIImage(named: "barButtonBackground")
    let rightBarImage = UIImage(named: "navBarAddButtonImage")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneListTableView.delegate = self
        phoneListTableView.dataSource = self
        searchBar.delegate = self

        getData()
        navBarSpecs()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name:NSNotification.Name(rawValue: "newData") , object: nil)
    }
    
    @objc func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
        let sortData = NSSortDescriptor(key: "name", ascending: true)
        
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [sortData]
        do{
            contacts = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print ("Error")
        }
        self.phoneListTableView.reloadData()
    }
    @objc func addButtonClicked(){
        selectedContact = ""
        performSegue(withIdentifier: "toAddContactVC", sender: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
            
            fetchRequest.predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                contacts = try context.fetch(fetchRequest) as! [NSManagedObject]
            }catch {
                print("search error")
            }
            
        }else {
            getData()
        }
        
        self.phoneListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsListCell", for: indexPath) as! ContactsListTableViewCell
        let contact = contacts[indexPath.row]
        
        cell.nameLabel.text = contact.value(forKey: "name") as? String
        cell.surnameLabel.text = contact.value(forKey: "surname") as? String
        cell.birthdateLabel.text = contact.value(forKey: "birthdate") as? String
        cell.emailLabel.text = contact.value(forKey: "email") as? String
        cell.areaLabel.text = contact.value(forKey: "areaPicker") as? String
        cell.phoneNumberLabel.text = contact.value(forKey: "phoneNumber") as? String
        cell.noteTextView.text = contact.value(forKey: "note") as? String

        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AddContactsViewController
        if segue.identifier == "toAddContactVC" {
            
            destinationVC.chosenContact = selectedContact
            destinationVC.chosenContactID = selectedContactID
        }
        if segue.identifier == "toUpdateContactVC"{
            
            destinationVC.chosenContact = selectedContact
            destinationVC.chosenContactID = selectedContactID
            destinationVC.toggleButton = "1"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        
        selectedContact = contact.value(forKey: "name") as! String
        selectedContactID = contact.value(forKey: "id") as? UUID

        performSegue(withIdentifier: "toUpdateContactVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contacts[indexPath.row])
            
            do{
                try context.save()
                
            } catch {
                print("delete error")
            }
            getData()
            phoneListTableView.reloadData()
            
        }
    }
    func navBarSpecs(){
        searchBar.setBackgroundImage(navBarBackground, for: .any, barMetrics: .default)
        searchBar.placeholder = "Kişi Ara"
        searchBar.searchTextField.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.topItem?.title = "Kişiler"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.setBackgroundImage(rightBarBackground, for: UIControl.State.normal, barMetrics: .default)
        navigationController?.navigationBar.setBackgroundImage(navBarBackground, for: .default)
    }
}

