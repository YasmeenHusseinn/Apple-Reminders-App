//
//  TaskCell.swift
//

import UIKit

// A cell to display a task
class TaskCell: UITableViewCell {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    // The closure called, passing in the associated task, when the "Complete" button is tapped.
    var onCompleteButtonTapped: ((Task) -> Void)?

    // The task associated with the cell
    var task: Task!

    // The function called when the "Complete" button is tapped.

    @IBAction func didTapCompleteButton(_ sender: UIButton) {
        // 1.
        task.isComplete = !task.isComplete
        // 2.
        update(with: task)
        // 3.
        onCompleteButtonTapped?(task)
    }

    // Initial configuration of the task cell

    func configure(with task: Task, onCompleteButtonTapped: ((Task) -> Void)?) {
        // 1.
        self.task = task
        // 2.
        self.onCompleteButtonTapped = onCompleteButtonTapped
        // 3.
        update(with: task)
    }

    // Update the UI for the given task
    // The complete button's image has already been configured in the storyboard for default and selected states.
    private func update(with task: Task) {
        // 1.
        titleLabel.text = task.title
        noteLabel.text = task.note
        // 2.
        noteLabel.isHidden = task.note == "" || task.note == nil
        // 3.
        titleLabel.textColor = task.isComplete ? .secondaryLabel : .label
        // 4.
        completeButton.isSelected = task.isComplete
        // 5.
        completeButton.tintColor = task.isComplete ? .systemBlue : .tertiaryLabel
    }

    // This overrides the table view cell's default selected and highlighted behavior to do nothing, otherwise, the row would darken when tapped
    // This is just a design / UI polish for this particular use case. Since we also have the "Completed" button in the row, it looks kinda weird if the whole cell darkens during selection.
    override func setSelected(_ selected: Bool, animated: Bool) { }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
}
