//
//  TaskListViewController.swift
//

import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // An "Empty State" label to show when there aren't any tasks.
    @IBOutlet weak var emptyStateLabel: UILabel!

    // The main tasks array initialized with a default value of an empty array.
    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide top cell separator
        tableView.tableHeaderView = UIView()

        // Set table view data source
        // Needed for standard table view setup:
        //    - tableView(numberOfRowsInSection:)
        //    - tableView(cellForRowAt:)
        // Also for swipe to delete row:
        //    - tableView(_:commit:forRowAt:)
        tableView.dataSource = self

        // Set table view delegate
        // Needed to detect row selection: tableView(_:didSelectRowAt:)
        tableView.delegate = self
    }

    // Refresh the tasks list each time the view appears in case any tasks were updated on the other tab.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshTasks()
    }

    // When the "+" button is tapped, perform the segue with id, "ComposeSegue".
    @IBAction func didTapNewTaskButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }

    // Prepare for navigation to the Task Compose View Controller.
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ComposeSegue" {
            if let composeNavController = segue.destination as? UINavigationController,

               let composeViewController = composeNavController.topViewController as? TaskComposeViewController {
                composeViewController.taskToEdit = sender as? Task
                composeViewController.onComposeTask = { [weak self] task in
                    task.save()
                    self?.refreshTasks()
                }
            }
        }
    }

    // MARK: - Helper Functions
    
    // Refresh all tasks
    private func refreshTasks() {

        var tasks = Task.getTasks()

        tasks.sort { lhs, rhs in
            if lhs.isComplete && rhs.isComplete {
                return lhs.completedDate! < rhs.completedDate!
            } else if !lhs.isComplete && !rhs.isComplete {

                return lhs.createdDate < rhs.createdDate
            } else {
                return !lhs.isComplete && rhs.isComplete
            }
        }

        self.tasks = tasks
        emptyStateLabel.isHidden = !tasks.isEmpty
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// MARK: - Table View Data Source Methods

// An extension to group all table view data source related methods
extension TaskListViewController: UITableViewDataSource {

    // The number of rows to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    // Create and configure a cell for each row of the table view (i.e. each task in the tasks array)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        // 2.
        let task = tasks[indexPath.row]
        // 3.
        cell.configure(with: task, onCompleteButtonTapped: { [weak self] task in
            // i.
            task.save()
            // ii.
            self?.refreshTasks()
        })
        // 4.
        return cell
    }

    // Enable "Swipe to Delete" functionality. The existence of this data source method enables the default "Swipe to Delete".
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            Task.save(tasks)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Table View Delegate Methods

// An extension to group all table view delegate related methods
extension TaskListViewController: UITableViewDelegate {

    // The table view delegate method called when a row is selected.
    // In this case, the user has tapped an existing task row and we want to segue them to the Compose View Controller to edit the associated task.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedTask = tasks[indexPath.row]
        performSegue(withIdentifier: "ComposeSegue", sender: selectedTask)
    }
}
