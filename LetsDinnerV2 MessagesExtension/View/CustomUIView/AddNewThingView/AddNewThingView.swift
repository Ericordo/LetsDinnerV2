//
//  NewThingView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 10/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol AddThingDelegate: class {
    func doneEditThing()
}

class AddNewThingView: UIView {
    
    var sectionNames: [String]? {
        didSet {
            self.updateSectionSelectedInput()
        }
    }
    var selectedSection: String?
    weak var addThingDelegate: AddThingDelegate?
    
    let containerView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .backgroundSystemColor
        return view
    }()
    
    let newThingTitleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.autocapitalizationType = .sentences
        textField.placeholder = "e.g. Milk"
        textField.textAlignment = .left
        textField.sizeToFit()
        textField.tag = 10
        textField.returnKeyType = .next
        return textField
    }()
    
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = "500"
        textField.keyboardType = .decimalPad
        textField.textAlignment = .right
        textField.sizeToFit()
        textField.tag = 20
        textField.returnKeyType = .next
        return textField
    }()
    
    let unitTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.textAlignment = .right
        textField.placeholder = "ml"
        textField.sizeToFit()
        textField.tag = 30
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        return textField
    }()
    
    let dragIndicator: UIView = {
        let indicator = UIView()
        indicator.frame = CGRect(x: 0, y: 0, width: 36, height: 5)
        indicator.backgroundColor = UIColor.keyboardBackground
        indicator.layer.cornerRadius = 3
        return indicator
    }()
    
    let sectionSelectionInput = SectionSelectionInput()
    
    init(sectionNames: [String], selectedSection: String?) {
        self.sectionNames = sectionNames
        self.selectedSection = selectedSection
        super.init(frame: CGRect.zero)
        configureUI(sectionNames: sectionNames, selectedSection: selectedSection)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI(sectionNames: sectionNames!, selectedSection: selectedSection!)
    }
    
    override func layoutSubviews() {
        addConstraints()
    }
    
    private func configureUI(sectionNames: [String], selectedSection: String?) {
        newThingTitleTextField.delegate = self
        amountTextField.delegate = self
        unitTextField.delegate = self
        sectionSelectionInput.sectionSelectionInputDelegate = self

        containerView.roundCorners([.topLeft, .topRight], radius: 10)
        
        if let selectedSection = selectedSection {
            updateSelectedSection(sectionName: selectedSection)
        }
        
        sectionSelectionInput.configureInput(sections: sectionNames)
   
    }
    
    private func updateSectionSelectedInput() {
        guard var sectionNames = self.sectionNames else { return }
        
        // Remove duplication
        for (i , name) in sectionNames.enumerated() {
            if name == "Miscellaneous" {
                sectionNames.remove(at: i)
            }
        }

        self.sectionSelectionInput.sections.removeAll()
        
        // Recreate the sections everytime
        self.sectionSelectionInput.sections.append("Miscellaneous")
        self.sectionSelectionInput.sections += sectionNames
        self.sectionSelectionInput.sectionsCollectionView.reloadData()
    }
}

extension AddNewThingView: SectionSelectionInputDelegate {
    func updateSelectedSection(sectionName: String) {
        self.selectedSection = sectionName
    }
    
    
}

// MARK: TextField Delegate


extension AddNewThingView: UITextFieldDelegate {
    
    // Add things
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case newThingTitleTextField:
            amountTextField.becomeFirstResponder()
        case amountTextField:
            unitTextField.becomeFirstResponder()
        case unitTextField:
            addThing(textField: textField)
            textField.resignFirstResponder()
        default:
            break
        }
        return true
        
    }
    
    private func addThing(textField: UITextField) {
        if !newThingTitleTextField.text!.isEmpty {
            let newTask = Task(taskName: newThingTitleTextField.text!,
                               assignedPersonUid: "nil",
                               taskState: TaskState.unassigned.rawValue,
                               taskUid: "nil",
                               assignedPersonName: "nil",
                               isCustom: true,
                               parentRecipe: self.selectedSection ?? "Miscellaneous")
            
            // If metricAmount has been inputted
            if !amountTextField.text!.isEmpty && !unitTextField.text!.isEmpty {
                newTask.metricUnit = unitTextField.text!
                newTask.metricAmount = Double(amountTextField.text!)
            }
            Event.shared.tasks.append(newTask)
            
            // Work on ManagmentVC
            addThingDelegate?.doneEditThing()

        }
        
        newThingTitleTextField.text = ""
        amountTextField.text = ""
        unitTextField.text = ""

    }
    
    
    // Check textField Length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Guarding character limit
        guard let textFieldText = textField.text, let rangeOfTextToReplace = Range(range, in: textFieldText) else { return false }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
    
        switch textField {
        case newThingTitleTextField:
            return count <= 30
        case amountTextField:
            let isNumberValidated = isValidatedNumber(textField: textField, string: string)
            return count <= 8 && isNumberValidated
        case unitTextField:
            return count <= 10
        default:
            return count <= 0
        }

    }
    
    private func isValidatedNumber(textField: UITextField, string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")

        if filtered == string {
            return true
        } else {
            if string == "." {
                let countdots = textField.text!.components(separatedBy:".").count - 1
                if countdots == 0 {
                    return true
                }else{
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            }else{
                return false
            }
        }
    }
    
    
}

extension AddNewThingView {
    private func addConstraints() {
        self.addSubview(containerView)
        self.addSubview(newThingTitleTextField)
        self.addSubview(amountTextField)
        self.addSubview(unitTextField)
        self.addSubview(sectionSelectionInput)
        self.addSubview(dragIndicator)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        newThingTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        unitTextField.translatesAutoresizingMaskIntoConstraints = false
        sectionSelectionInput.translatesAutoresizingMaskIntoConstraints = false
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        containerView.heightAnchor.constraint(equalToConstant: 94).isActive = true
        
        newThingTitleTextField.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
        newThingTitleTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        newThingTitleTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        newThingTitleTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 17).isActive = true
        
        amountTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        amountTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        amountTextField.leadingAnchor.constraint(equalTo: newThingTitleTextField.trailingAnchor, constant: 5).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: unitTextField.leadingAnchor, constant: -4).isActive = true
        amountTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        amountTextField.centerYAnchor.constraint(equalTo: newThingTitleTextField.centerYAnchor).isActive = true
        
        unitTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unitTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        unitTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -17).isActive = true
        unitTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        unitTextField.centerYAnchor.constraint(equalTo: newThingTitleTextField.centerYAnchor).isActive = true
        

        
        sectionSelectionInput.topAnchor.constraint(equalTo: newThingTitleTextField.bottomAnchor).isActive = true
        sectionSelectionInput.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        sectionSelectionInput.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        sectionSelectionInput.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        dragIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        dragIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dragIndicator.heightAnchor.constraint(equalToConstant: 5).isActive = true
        dragIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        
        
    }
}
