//
//  TodoViewController.swift
//  Tick
//
//  Created by Satyam Sovan Mishra on 09/09/23.
//

import UIKit

class TodoViewController: UIViewController {
    var todoManager = TodoManager()
    let commonService = CommonService()
    var token: String = ""
    var todos: [TodoRequest] = []
    var message: String = K.errorMessage.genericError
    var newTodo: String = ""
    var newTodoElement = TodoRequest(isComplete: false, todo: "")
    var action = ""
    
    @IBOutlet weak var todoView: UITableView!
    @IBOutlet weak var deleteAllTodosButton: UIButton!
    @IBOutlet weak var todoList: UITableView!
    @IBOutlet weak var addTodoTextField: UITextField!
    @IBOutlet weak var addTodoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonService.logger("Token is: \(token)")
        navigationItem.hidesBackButton = true
        todoList.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        todoList.dataSource = self
        todoManager.delegate = self
        addTodoTextField.delegate = self
        
        self.disableButtonsAndShowLoader()
        todoManager.getTodos(token: token)
    }
    
    @IBAction func addTodoPressed(_ sender: UIButton) {
        if(addTodoTextField.text != "") {
            self.disableButtonsAndShowLoader()
            addTodoTextField.endEditing(true)
            let newTodo = TodoRequest(isComplete: false, todo: addTodoTextField.text ?? "")
            newTodoElement = TodoRequest(isComplete: false, todo: addTodoTextField.text ?? "")
            action = "add"
            todoManager.updateTodos(todoRequest: newTodo, action: action, token: token)
        }
    }
    
    @IBAction func deleteAllTodos(_ sender: UIButton) {
        self.disableButtonsAndShowLoader()
        action = "delete"
        todoManager.updateTodos(todoRequest: nil, action: action, token: token)
        todos = []
    }
    
    @IBAction func signoutPressed(_ sender: UIBarButtonItem) {
        token = ""
        action = ""
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == K.App.todoToInformation) {
            let destinationViewController = segue.destination as! InformationViewController
            destinationViewController.message = message
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func disableButtonsAndShowLoader() {
        addTodoButton.isEnabled = false
        deleteAllTodosButton.isEnabled = false
        self.addTodoButton.configuration?.showsActivityIndicator = true
        self.deleteAllTodosButton.configuration?.showsActivityIndicator = true
    }
    
    func enableButtonsAndHideLoader() {
        addTodoButton.isEnabled = true
        deleteAllTodosButton.isEnabled = true
        self.addTodoButton.configuration?.showsActivityIndicator = false
        self.deleteAllTodosButton.configuration?.showsActivityIndicator = false
    }
    
}

extension TodoViewController: TodoManagerDelegate {
    func didReceiveTodos(_ todoManager: TodoManager, response: TodoResponse) {
        DispatchQueue.main.async {
            self.commonService.logger(response)
            self.message = response.message
            if(self.message != K.successMessage.todoRetrivalSuccessful) {
                self.performSegue(withIdentifier: K.App.todoToInformation, sender: self)
            } else {
                self.todos = response.data!
                self.todoView.reloadData()
            }
            self.enableButtonsAndHideLoader()
        }
        
    }
    
    func didUpdateTodos(_ todoManager: TodoManager, response: TodoResponse) {
        DispatchQueue.main.async {
            self.commonService.logger(response)
            
            self.message = response.message
            if(self.message != K.successMessage.todoAdditionSuccessful &&
               self.message != K.successMessage.todoDeletionSuccessful) {
                self.performSegue(withIdentifier: K.App.todoToInformation, sender: self)
            } else {
                self.commonService.logger(self.newTodoElement)

                if(self.action == "add") {
                    self.todos.append(self.newTodoElement)
                }
                
                self.todoView.reloadData()
                self.addTodoTextField.text = ""
                self.newTodoElement = TodoRequest(isComplete: false, todo: "")
                self.showAlert(title: K.successMessage.genricSuccessful, message: self.message)
                self.action = ""
            }
            self.enableButtonsAndHideLoader()
        }
        
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.addTodoTextField.text = ""
            self.newTodoElement = TodoRequest(isComplete: false, todo: "")
            self.commonService.logger(error)
            self.performSegue(withIdentifier: K.App.todoToInformation, sender: self)
            self.enableButtonsAndHideLoader()
            self.action = ""
        }
    }
    
    
}

extension TodoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.todoLabel?.text = todo.todo
        return cell
    }
}

extension TodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(addTodoTextField.text != "") {
            newTodo = addTodoTextField.text ?? ""
            addTodoTextField.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(addTodoTextField.text != "") {
            newTodo = addTodoTextField.text ?? ""
            addTodoTextField.endEditing(true)
        }
        return true
    }
}

