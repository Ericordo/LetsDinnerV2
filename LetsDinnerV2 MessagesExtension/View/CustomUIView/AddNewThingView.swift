//
//  NewThingView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 10/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

enum AddNewThingViewType {
    case createRecipe
    case manageTask
}

enum MainTextFieldCharacterLimit: Int {
    case name = 30
    case ingredient = 25
    case step = 50
    case comment = 200
}

protocol AddThingDelegate: class {
    func doneEditThing(selectedSection: String?,
                       item: String?,
                       amount: String?,
                       unit: String?)
}

class AddNewThingView: UIView {
    
    weak var addThingDelegate: AddThingDelegate?

    var type: AddNewThingViewType!
    var sectionNames: [String]? {
        didSet {
            self.updateSectionSelectedInputCV()
        }
    }
    var selectedSection: String? {
        didSet {
//            self.updateUI(type: type, selectedSection: selectedSection)
        }
    }
    
    // UILayout Variable
    var amountTextFieldWidthConstraint: NSLayoutConstraint!
    var unitTextFieldWidthConstraint: NSLayoutConstraint!
    
    let containerView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .backgroundSystemColor
        view.addShadow()
        return view
    }()

    let mainTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .textLabel
        textField.font = .systemFont(ofSize: 17)
        textField.autocapitalizationType = .sentences
        textField.placeholder = LabelStrings.ingredientPlaceholder
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
        textField.placeholder = LabelStrings.amountOnlyPlaceholder
        textField.keyboardType = .numbersAndPunctuation
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
        textField.placeholder = LabelStrings.unitOnlyPlaceholder
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
    
    let addButton: UIButton = {
        let image = Images.addTask
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setBackgroundImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var shadowLayer: CAShapeLayer!
    
    lazy var sectionSelectionInput = SectionSelectionInput(type: type)
        
    init(type: AddNewThingViewType, sectionNames: [String], selectedSection: String?) {
        
        let section: String = {
            let section: String!
            switch type {
            case .createRecipe:
                section = DefaultSectionName.name.labelString
            case .manageTask:
                section = DefaultSectionName.miscellaneous.labelString
            }
            return section
        }()

        self.type = type
        self.sectionNames = sectionNames
        self.selectedSection = selectedSection ?? section
        super.init(frame: CGRect.zero)
        
        configureView(sectionNames: sectionNames, selectedSection: selectedSection)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addShadowLayer()
    }
    
    // MARK: Configure UI
    private func configureView(sectionNames: [String], selectedSection: String?) {
        
        self.backgroundColor = .backgroundSystemColor

        // Set Corners for childView
        containerView.roundCorners([.topLeft, .topRight], radius: 10)
                
        if let selectedSection = selectedSection {
            updateSelectedSection(sectionName: selectedSection)
        }
        
        self.sectionSelectionInput.configureInput(sections: sectionNames)
//        self.setDefaultSelectedSection(type: type)
        
        self.addConstraints()
        
        mainTextField.delegate = self
        amountTextField.delegate = self
        unitTextField.delegate = self
        sectionSelectionInput.sectionSelectionInputDelegate = self
    }
    
    // MARK: Update UI
    func updateUIAfterPressingAddButton(type: AddNewThingViewType, selectedSection: String?) {
        var position = 0
        if type == .createRecipe {
            switch selectedSection {
            case CreateRecipeSections.name.rawValue:
                position = 0
                mainTextField.returnKeyType = .done
                mainTextField.placeholder = LabelStrings.recipeNamePlaceholder
                hideAmountAndUnitTextField(true)
            case CreateRecipeSections.ingredient.rawValue:
                position = 1
                mainTextField.returnKeyType = .next
                mainTextField.placeholder = LabelStrings.ingredientPlaceholder
                hideAmountAndUnitTextField(false)
            case CreateRecipeSections.step.rawValue:
                position = 2
                mainTextField.returnKeyType = .done
                mainTextField.placeholder = LabelStrings.stepPlaceholder
                hideAmountAndUnitTextField(true)
            case CreateRecipeSections.comment.rawValue:
                position = 3
                mainTextField.returnKeyType = .done
                mainTextField.placeholder = LabelStrings.cookingTipPlaceholder
                hideAmountAndUnitTextField(true)
            default:
                break
            }
        } else if type == .manageTask {
            
            guard let sectionNames = sectionNames else { return }
            for (index, sectionName) in sectionNames.enumerated() {
                if selectedSection == LabelStrings.misc {
                    position = 0
                    break
                } else if selectedSection == sectionName {
                    position = index + 1
                    break
                }
            }
        }
        
        // Move the bubble to corresponding SectionInputCV
        sectionSelectionInput.sectionsCollectionView.selectItem(at: [0, position], animated: true, scrollPosition: .top)
        
//        mainTextField.becomeFirstResponder()
    }
    
    private func hideAmountAndUnitTextField(_ bool: Bool) {
        amountTextField.isHidden = bool
        unitTextField.isHidden = bool
        
        amountTextFieldWidthConstraint.isActive = false
        unitTextFieldWidthConstraint.isActive = false
        
        amountTextFieldWidthConstraint = (bool) ?  amountTextField.widthAnchor.constraint(equalToConstant: 0) : amountTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        unitTextFieldWidthConstraint = (bool) ? unitTextField.widthAnchor.constraint(equalToConstant: 0) :
            amountTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        
        amountTextFieldWidthConstraint.isActive = true
        unitTextFieldWidthConstraint.isActive = true
        self.layoutIfNeeded()
    }

    
    private func updateSectionSelectedInputCV() {
        guard var sectionNames = self.sectionNames else { return }
        
        // Remove duplication
        for (i , name) in sectionNames.enumerated() {
            if name == DefaultSectionName.miscellaneous.labelString {
                sectionNames.remove(at: i)
            }
        }

        self.sectionSelectionInput.sections.removeAll()
        
        // Recreate the sections everytime
        if type == .manageTask {
            self.sectionSelectionInput.sections.insert(DefaultSectionName.miscellaneous.labelString, at: 0)
        }
        
        self.sectionSelectionInput.sections += sectionNames
    }
    
    private func setDefaultSelectedSection(type: AddNewThingViewType) {
        if selectedSection == nil {
            switch type {
            case .createRecipe:
                selectedSection = DefaultSectionName.name.labelString
            case .manageTask:
                selectedSection = DefaultSectionName.miscellaneous.labelString
            }
        }
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
        
        if type == .manageTask || selectedSection == CreateRecipeSections.ingredient.rawValue {
            
            switch textField {
            case mainTextField:
                amountTextField.becomeFirstResponder()
            case amountTextField:
                unitTextField.becomeFirstResponder()
            case unitTextField:
                addThing(type: type)
                textField.resignFirstResponder()
            default:
                break
            }
        } else {
            
            if textField == mainTextField {
                addThing(type: type)
                textField.resignFirstResponder()
            }
        }
  
        return true
    }
    
    private func addThing(type: AddNewThingViewType) {
        guard let item = mainTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !item.isEmpty else { return mainTextField.shake() }
        
        switch type {
        case .createRecipe:
            // Pass selectedSection and the content to CreateRecipeVC
            addThingDelegate?.doneEditThing(selectedSection: selectedSection,
                                            item: item,
                                            amount: amountTextField.text,
                                            unit: unitTextField.text)
           
        case .manageTask:
            let taskName = item
            let amount = amountTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let unit = unitTextField.text!

            // Pass to Global Varaible
            let newTask = Task(taskName: taskName,
                               assignedPersonUid: "nil",
                               taskState: TaskState.unassigned.rawValue,
                               taskUid: "nil",
                               assignedPersonName: "nil",
                               isCustom: amount.isEmpty,
                               parentRecipe: self.selectedSection ?? DefaultSectionName.miscellaneous.labelString)
            if !amount.isEmpty {
                newTask.metricAmount = amount.doubleValue
                newTask.servings = Event.shared.servings
                newTask.metricUnit = unit
            }
                
            Event.shared.tasks.append(newTask)
            
            // Work on ManagmentVC
            addThingDelegate?.doneEditThing(selectedSection: nil, item: nil, amount: nil, unit: nil)
            
            self.updateUIAfterPressingAddButton(type: .manageTask, selectedSection: selectedSection)
        }
        
        self.clearAllTextField()

    }
    
    @objc func addButtonTapped(sender: UIButton) {
        self.addThing(type: type)
    }
    
    private func clearAllTextField() {
        [mainTextField, amountTextField, unitTextField].forEach {
            $0.text = ""
        }
    }
    
    // MARK: Validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Guarding count limit
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else { return false }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        switch textField {
        case mainTextField:
            switch selectedSection {
            case CreateRecipeSections.name.rawValue :
                return count <= MainTextFieldCharacterLimit.name.rawValue
            case CreateRecipeSections.ingredient.rawValue:
                return count <= MainTextFieldCharacterLimit.ingredient.rawValue
            case CreateRecipeSections.step.rawValue:
                return count <= MainTextFieldCharacterLimit.step.rawValue
            case CreateRecipeSections.comment.rawValue:
                return count <= MainTextFieldCharacterLimit.comment.rawValue
            default:
                return count <= 30
            }
        case amountTextField:
            return count <= 8 && isNumberValidated(textField: textField, string: string)
        case unitTextField:
            return count <= 10
        default:
            return count <= 0
        }
    }
    
    private func isNumberValidated(textField: UITextField, string: String) -> Bool {
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
                } else {
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            } else {
                return false
            }
        }
    }
}

extension AddNewThingView {
    // MARK: Constraints
    private func addConstraints() {
        self.addSubview(containerView)
        containerView.addSubview(mainTextField)
        containerView.addSubview(amountTextField)
        containerView.addSubview(unitTextField)
        containerView.addSubview(sectionSelectionInput)
        containerView.addSubview(dragIndicator)
        containerView.addSubview(addButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        mainTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        unitTextField.translatesAutoresizingMaskIntoConstraints = false
        sectionSelectionInput.translatesAutoresizingMaskIntoConstraints = false
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Init Constraint
        amountTextFieldWidthConstraint = amountTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        unitTextFieldWidthConstraint = unitTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        
        containerView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        containerView.heightAnchor.constraint(equalToConstant: 94).isActive = true
        
        mainTextField.setContentHuggingPriority(.init(rawValue: 249), for: .horizontal)
        mainTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        mainTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mainTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 17).isActive = true
        
        amountTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        amountTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        amountTextField.leadingAnchor.constraint(equalTo: mainTextField.trailingAnchor, constant: 5).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: unitTextField.leadingAnchor, constant: -4).isActive = true
        
        amountTextFieldWidthConstraint.isActive = true
//        amountTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        amountTextField.centerYAnchor.constraint(equalTo: mainTextField.centerYAnchor).isActive = true
        
        unitTextField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        unitTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        unitTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -17).isActive = true
        unitTextFieldWidthConstraint.isActive = true
//        unitTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        unitTextField.centerYAnchor.constraint(equalTo: mainTextField.centerYAnchor).isActive = true

        sectionSelectionInput.topAnchor.constraint(equalTo: mainTextField.bottomAnchor).isActive = true
        sectionSelectionInput.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        sectionSelectionInput.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -5).isActive = true
        sectionSelectionInput.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        dragIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        dragIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dragIndicator.heightAnchor.constraint(equalToConstant: 5).isActive = true
        dragIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
        
        addButton.centerYAnchor.constraint(equalTo: sectionSelectionInput.centerYAnchor).isActive = true
        addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func addShadowLayer() {
        guard shadowLayer == nil else { return }

        shadowLayer = CAShapeLayer()
          
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        shadowLayer.fillColor = UIColor.black.cgColor

        shadowLayer.shadowColor = Colors.separatorGrey.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 0.7
        shadowLayer.shadowRadius = 10
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
}
