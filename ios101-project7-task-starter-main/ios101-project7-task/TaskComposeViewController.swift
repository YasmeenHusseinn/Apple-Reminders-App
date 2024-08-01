//
//  TaskComposeViewController.swift
//

import UIKit

class TaskComposeViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextField!

    // A UI element that allows users to pick a date.
    @IBOutlet weak var datePicker: UIDatePicker!

    // The optional task to edit.
    // If a task is present we're in "Edit Task" mode
    // Otherwise we're in "New Task" mode
    var taskToEdit: Task?

    // When a new task is created (or an existing task is edited), this closure is called
    // passing in the task as an argument so it can be used by whoever presented the TaskComposeViewController.
    var onComposeTask: ((Task) -> Void)? = nil

    // When the view loads, do initial setup for the view controller.

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.
        if let task = taskToEdit {
            titleField.text = task.title
            noteField.text = task.note
            datePicker.date = task.dueDate

            // 2.
            self.title = "Edit Task"
        }
    }

    // The function called when the "Done" button is tapped.
    @IBAction func didTapDoneButton(_ sender: Any) {

        guard let title = titleField.text,
              !title.isEmpty
        else {
            presentAlert(title: "Oops...", message: "Make sure to add a title!")
            return
        }

        var task: Task
        if let editTask = taskToEdit {
            task = editTask
            task.title = title
            task.note = noteField.text
            task.dueDate = datePicker.date
        } else {
            task = Task(title: title,
                        note: noteField.text,
                        dueDate: datePicker.date)
        }
        onComposeTask?(task)
        dismiss(animated: true)
    }

    // The cancel button was tapped.
    @IBAction func didTapCancelButton(_ sender: Any) {
        // Dismiss the TaskComposeViewController.
        dismiss(animated: true)
    }

    // A helper method to present an alert given a title and message.
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
