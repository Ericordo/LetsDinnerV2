//
//  PDFCreator.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 24/06/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import PDFKit

class PDFCreator {
    
    private let recipes = Event.shared.selectedRecipes
    private var proprietaryRecipes : [LDRecipe] {
        return Event.shared.selectedCustomRecipes + Event.shared.selectedPublicRecipes
    }
    
    private let pageWidth       : CGFloat = 585
    private let pageHeight      : CGFloat = 842
    private let marginSide      : CGFloat = 20
    private let marginTop       : CGFloat = 40
    private let marginBottom    : CGFloat = 36
    
    private let textFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    private let subtextFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    
    private let paragraphStyle : NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = .natural
        style.lineBreakMode = .byWordWrapping
        return style
    }()
    
    private lazy var textAttributes = [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font: textFont
    ]
    
    private lazy var subtextAttributes = [
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
        NSAttributedString.Key.font: subtextFont
    ]
    
    init() {}
    
    func createBook() -> Data {
        
        let pdfMetaData = [
            kCGPDFContextCreator: LabelStrings.letsdinner,
            kCGPDFContextAuthor: LabelStrings.letsdinner,
            kCGPDFContextTitle: Event.shared.dinnerName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String : Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            
            recipes.forEach { recipe in
                startNewPage(context: context, pageRect: pageRect)
                let titleBottom = addTitle(recipeName: recipe.title, pageRect: pageRect)
                var topPosition : CGFloat = titleBottom + 15.0
                let imageBottom = addImage(imageUrl: recipe.imageUrl ?? "", pageRect: pageRect, imageTop: topPosition)
                topPosition = imageBottom + 15
                if let url = recipe.sourceUrl {
                    let linkBottom = addLink(recipeUrl: url, pageRect: pageRect, linkTop: topPosition)
                    topPosition = linkBottom + 15.0
                }
                if Event.shared.tasks.contains(where: { $0.parentRecipe == recipe.title }) {
                    let ingredientsBottom = addIngredients(recipeName: recipe.title, pageRect: pageRect, textTop: topPosition)
                    topPosition = ingredientsBottom + 10
                }
                if let steps = recipe.instructions, !steps.isEmpty {
                    let procedureTitleBottom = addProcedureTitle(pageRect: pageRect, textTop: topPosition)
                    addSteps(steps: recipe.instructions ?? [], pageRect: pageRect, textTop: procedureTitleBottom + 15.0, context: context)
                }
            }
            
            proprietaryRecipes.forEach { recipe in
                startNewPage(context: context, pageRect: pageRect)
                let titleBottom = addTitle(recipeName: recipe.title, pageRect: pageRect)
                var topPosition : CGFloat = titleBottom + 15.0
                let imageBottom = addImage(imageUrl: recipe.downloadUrl ?? "", pageRect: pageRect, imageTop: topPosition)
                topPosition = imageBottom + 15
                
                if !recipe.comments.isEmpty {
                    let commentTitleBottom = addCommentTitle(pageRect: pageRect, textTop: topPosition)
                    let commentsBottom = addComments(comments: recipe.comments, pageRect: pageRect, textTop: commentTitleBottom + 15.0)
                    topPosition = commentsBottom + 10
                }
                
                if Event.shared.tasks.contains(where: { $0.parentRecipe == recipe.title }) {
                    let ingredientsBottom = addIngredients(recipeName: recipe.title, pageRect: pageRect, textTop: topPosition)
                    topPosition = ingredientsBottom + 10
                }
                if !recipe.cookingSteps.isEmpty {
                    let procedureTitleBottom = addProcedureTitle(pageRect: pageRect, textTop: topPosition)
                    addSteps(steps: recipe.cookingSteps, pageRect: pageRect, textTop: procedureTitleBottom + 15.0, context: context)
                }
            }
        }
        return data
    }
    
    private func startNewPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect) {
        context.beginPage()
        addAppLogo(pageRect: pageRect)
    }
    
    private func addAppLogo(pageRect: CGRect) {
        let maxHeight : CGFloat = 48
        let maxWidth : CGFloat = 36
        
        let image = Images.pdfLogo

        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio

        let imageRect = CGRect(x: 10, y: 10,
        width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
        
        let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: LabelStrings.letsdinner, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        
        let titleStringRect = CGRect(x: imageRect.origin.x + imageRect.size.width + 10.0,
                                     y: (10 + (imageRect.size.height/2)) - titleStringSize.height/2,
                                     width: titleStringSize.width,
                                     height: titleStringSize.height)

        attributedTitle.draw(in: titleStringRect)
    }
 
    private func addTitle(recipeName: String, pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)

        let titleAttributes: [NSAttributedString.Key: Any] =
            [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: recipeName, attributes: titleAttributes)

        let titleStringSize = attributedTitle.size()

        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
                                     y: marginTop, width: titleStringSize.width,
                                     height: titleStringSize.height)

        attributedTitle.draw(in: titleStringRect)

        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    private func addImage(imageUrl: String, pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
        let maxHeight = pageRect.height * 0.1
        let maxWidth = pageRect.width * 0.2
        
        var image = Images.pdfLogo
        let url = URL(string: imageUrl)
        if let url = url {
            let data = try? Data(contentsOf: url)
            if let data = data {
                if let recipeImage = UIImage(data: data) {
                    image = recipeImage
                }
            }
        }

        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio

        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: imageTop,
                               width: scaledWidth, height: scaledHeight)

        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
    
    private func addLink(recipeUrl: String, pageRect: CGRect, linkTop: CGFloat) -> CGFloat {
        let attributedTitle = NSAttributedString(string: String.localizedStringWithFormat(LabelStrings.link, recipeUrl),
                                                 attributes: subtextAttributes)

        let titleStringSize = attributedTitle.size()

        let titleStringRect = CGRect(x: marginSide,
                                     y: linkTop,
                                     width: titleStringSize.width,
                                     height: titleStringSize.height)

        attributedTitle.draw(in: titleStringRect)

        return titleStringRect.origin.y + titleStringRect.size.height
    }
    
    private func addIngredients(recipeName: String, pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: String.localizedStringWithFormat(LabelStrings.ingredientTitle, Event.shared.servings), attributes: textAttributes)
        
        let tasks = Event.shared.tasks
        tasks.forEach({ task in
            if task.parentRecipe == recipeName {
                let ingredientName = NSMutableAttributedString(string: "- \(task.name)", attributes: subtextAttributes)
                if let amount = task.amount {
                    ingredientName.append(NSAttributedString(string: ", \(formatAmount(amount))", attributes: subtextAttributes))
                }
                if let unit = task.unit {
                    ingredientName.append(NSAttributedString(string: " \(unit)", attributes: subtextAttributes))
                }
                ingredientName.append(NSAttributedString(string: "\n"))
                attributedText.append(ingredientName)
            }
        })
        
        let ingredientsStringSize = attributedText.size()
        
        let textRect = CGRect(x: marginSide, y: textTop, width: pageRect.width - marginSide,
                              height: ingredientsStringSize.height)
        attributedText.draw(in: textRect)
        return textRect.origin.y + textRect.size.height
    }
    
    private func addProcedureTitle(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: LabelStrings.instructions, attributes: textAttributes)
        
        let procedureStringSize = attributedText.size()

        let procedureStringRect = CGRect(x: marginSide,
                                     y: textTop, width: procedureStringSize.width,
                                     height: procedureStringSize.height)

        attributedText.draw(in: procedureStringRect)

        return procedureStringRect.origin.y + procedureStringRect.size.height
    }
    
    private func addSteps(steps: [String], pageRect: CGRect, textTop: CGFloat, context: UIGraphicsPDFRendererContext) {
        var stepNumber = 0
        var yPosition = textTop
        
        steps.forEach { step in
            stepNumber += 1
            let stepName = NSMutableAttributedString(string: "\(String(stepNumber)) - \(step)", attributes: subtextAttributes)
            let stepSize = stepName.boundingRect(with: pageRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)

            if yPosition > pageHeight - marginBottom {
                startNewPage(context: context, pageRect: pageRect)
                yPosition = marginTop + 5.0
            }
            let stepRect = CGRect(x: marginSide, y: yPosition, width: pageRect.width - marginSide - 20, height: stepSize.height)
             yPosition = yPosition + stepSize.height + 5
            
            stepName.draw(in: stepRect)
        }
    }
    
    private func addCommentTitle(pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        let attributedText = NSMutableAttributedString(string: LabelStrings.tipsAndComments, attributes: textAttributes)
        
        let procedureStringSize = attributedText.size()
        let procedureStringRect = CGRect(x: marginSide,
                                     y: textTop, width: procedureStringSize.width,
                                     height: procedureStringSize.height)

        attributedText.draw(in: procedureStringRect)

        return procedureStringRect.origin.y + procedureStringRect.size.height
    }
    
    private func addComments(comments: [String], pageRect: CGRect, textTop: CGFloat) -> CGFloat {
        
        var yPosition = textTop
        
        comments.forEach { comment in
            let attributedText = NSMutableAttributedString(string: comment, attributes: subtextAttributes)
            let commentsStringSize = attributedText.boundingRect(with: pageRect.size, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil)
            
            let textRect = CGRect(x: marginSide, y: yPosition, width: pageRect.width - marginSide - 20,
            height: commentsStringSize.height)
            yPosition = yPosition + commentsStringSize.height + 5
            
            attributedText.draw(in: textRect)
        }
        
        return yPosition
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount.truncatingRemainder(dividingBy: 1) == 0.0 {
            return String(format:"%.0f", amount)
        } else {
            return String(format:"%.1f", amount)
        }
    }
}
