//
//  CalendarViewController.swift
//

import UIKit

class CalendarViewController: UIViewController {

    // The array of all tasks to display in the calendar.
    var tasks: [Task] = []

    // The tasks who's due dates match the current selected calendar date.
    private var selectedTasks: [Task] = []

    private var calendarView: UICalendarView!

    @IBOutlet private weak var calendarContainerView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup the Table View
 
        tableView.dataSource = self
        // 2.
        tableView.tableHeaderView = UIView()
        // 3.
        setContentScrollView(tableView)

        //Create and add Calendar View to view hierarchy
        // 1.
        self.calendarView = UICalendarView()
        // 2.
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        // 3.
        calendarContainerView.addSubview(calendarView)
        // 4.
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])

        //Setup the Calendar View
        calendarView.delegate = self
        // 2.
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection

        //Set initial calendar selection
        tasks = Task.getTasks()
        // 2.
        let todayComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: Date())
        // 3.
        let todayTasks = filterTasks(for: todayComponents)
        // 4.
        if !todayTasks.isEmpty {
            // i.
            let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate
            // ii.
            selection?.setSelected(todayComponents, animated: false)
        }
    }

    // Refresh tasks anytime the view appears in case updates to any tasks were made on another tab.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshTasks()
    }

    //Helper Functions
    private func filterTasks(for dateComponents: DateComponents) -> [Task] {
        // 1.
        let calendar = Calendar.current
        // 2.
        guard let date = calendar.date(from: dateComponents) else {
            return []
        }
        // 3.
        let tasksMatchingDate = tasks.filter { task in
            // i.
            return calendar.isDate(task.dueDate, equalTo: date, toGranularity: .day)
        }
        // 4.
        return tasksMatchingDate
    }

    // Refresh the main tasks and update the calendar view and table view.
    private func refreshTasks() {
        // 1.
        tasks = Task.getTasks()
        // 2.
        tasks.sort { lhs, rhs in
            if lhs.isComplete && rhs.isComplete {
                return lhs.completedDate! < rhs.completedDate!
            } else if !lhs.isComplete && !rhs.isComplete {
                return lhs.createdDate < rhs.createdDate
            } else {
                return !lhs.isComplete && rhs.isComplete
            }
        }
        // 3.
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
            let selectedComponents = selection.selectedDate {

            selectedTasks = filterTasks(for: selectedComponents)
        }
        // 4.
        let taskDueDates = tasks.map(\.dueDate)
        // 5.
        var taskDueDateComponents = taskDueDates.map { dueDate in
            Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: dueDate)
        }
        // 6.
        taskDueDateComponents.removeDuplicates()
        // 7.
        calendarView.reloadDecorations(forDateComponents: taskDueDateComponents, animated: false)
        // 8.
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// MARK: - Calendar Delegate Methods
extension CalendarViewController: UICalendarViewDelegate {

    // Configure the decorations for each calendar date.

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // 1.
        let tasksMatchingDate = filterTasks(for: dateComponents)
        // 2.
        let hasUncompletedTask = tasksMatchingDate.contains { task in
            return !task.isComplete
        }
        // 3.
        if !tasksMatchingDate.isEmpty {
            // i.
            let image = UIImage(systemName: hasUncompletedTask ? "circle" : "circle.inset.filled")
            // ii.
            return .image(image, color: .systemBlue, size: .large)
        } else {
            // iii.
            return nil
        }
    }
}

// MARK: - Calendar Selection Delegate Methods
extension CalendarViewController: UICalendarSelectionSingleDateDelegate {

    // Similar to the `tableView(_:didSelectRowAt:)` delegate method, the Calendar View's `dateSelection(_:didSelectDate:)` delegate method is called whenever a user selects a date on the calendar.

    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        // 1.
        guard let components = dateComponents else { return }
        // 2.
        selectedTasks = filterTasks(for: components)
        // 3.
        if selectedTasks.isEmpty {
            selection.setSelected(nil, animated: true)
        }
        // 4.
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

// MARK: - Table View Datasource Methods
extension CalendarViewController: UITableViewDataSource {

    // The number of rows to show based on the number of selected tasks (i.e. tasks associated with the current selected date)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTasks.count
    }

    // Create and configure a cell for each row of the table view (i.e. each task in the selectedTasks array)
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        // 2.
        let task = selectedTasks[indexPath.row]
        // 3.
        cell.configure(with: task) { [weak self] task in
            // 1.
            task.save()
            // ii.
            self?.refreshTasks()
        }
        // 4.
        return cell
    }
}

extension Array where Element: Equatable, Element: Hashable {

    // A helper method to remove any duplicate values from an array.
   
    mutating func removeDuplicates() {
        // 1.
        let set = Set(self)
        // 2.
        self = Array(set)
    }
}
