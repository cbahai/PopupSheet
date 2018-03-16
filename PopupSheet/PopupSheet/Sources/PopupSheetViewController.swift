//
//  PopupSheetViewController.swift
//  PopupSheet
//
//  Created by Chai on 2018/3/16.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit

public protocol PopupSheetContent {}
extension UIView: PopupSheetContent {}
extension UIViewController: PopupSheetContent {}

public class PopupSheetViewController: UIViewController {
    
    /// 坐落位置枚举
    public enum Location {
        case top
        case bottom
        case left
        case right
    }
    
    /// 偏移量
    public var offset: CGFloat = 0
    /// 用来计算偏移量的视图
    public var offsetView: UIView?
    /// 在原有的偏移量额外添加的偏移量
    public var addOffset: CGFloat = 0
    /// 显示及消失回调
    public var callback: ((PopupSheetViewController, Bool/*显示(true);消失(false)*/) -> Void)?
    
    /// 内容
    var content: PopupSheetContent!
    /// 坐落位置
    var location: Location!
    
    @IBOutlet weak var contentContainerViewOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainerViewHiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var maskButton: UIButton!
    
    public static func newInstance(withContent content: PopupSheetContent, location: Location = .top) -> PopupSheetViewController {
        let bundle = Bundle(for: self.classForCoder())
        
        let identifier: String
        switch location {
        case .top:
            identifier = "top"
        case .bottom:
            identifier = "bottom"
        case .left:
            identifier = "left"
        case .right:
            identifier = "right"
        }
        
        let vc = UIStoryboard(name: "PopupSheet", bundle: bundle).instantiateViewController(withIdentifier: identifier) as! PopupSheetViewController
        vc.content = content
        vc.location = location
        
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 偏移量设置 {
        if let offsetView = self.offsetView {
            let frame = offsetView.superview!.convert(offsetView.frame, to: self.view)
            switch location! {
            case .top:
                offset = frame.origin.y + frame.height
            case .bottom: ()
            case .left: ()
            case .right: ()
            }
        }
        offset += addOffset
        // }
        
        maskButton.alpha = 0
        contentContainerViewHiddenConstraint.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
        contentContainerViewOffsetConstraint.constant = offset
        
        if let content = self.content as? UIView {
            contentContainerViewHeightConstraint.constant = content.frame.height
            add(subView: content, to: contentContainerView)
        } else if let content = self.content as? UIViewController {
            addChildViewController(content)
            contentContainerViewHeightConstraint.constant = content.view.frame.height
            add(subView: content.view, to: contentContainerView)
            content.didMove(toParentViewController: self)
        }
        
        self.view.layoutIfNeeded()
    }
    
    deinit {
        if let content = self.content as? UIViewController {
            content.willMove(toParentViewController: nil)
            content.view.removeFromSuperview()
            content.removeFromParentViewController()
        }
    }
    
    public func show(in viewController: UIViewController) {
        modalPresentationStyle = .overFullScreen
        viewController.present(self, animated: false) { [weak self] in
            guard let this = self else { return }
            UIView.animate(withDuration: 0.3, animations: { [weak this] in
                this?.maskButton.alpha = 1
                this?.contentContainerViewHiddenConstraint.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue - 1)
                this?.view.layoutIfNeeded()
            })
        }
        callback?(self, true)
    }
    
    public func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.maskButton.alpha = 0
            self?.contentContainerViewHiddenConstraint.priority = UILayoutPriority(UILayoutPriority.defaultHigh.rawValue + 1)
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] (finished) in
            guard let this = self else { return }
            if finished {
                this.dismiss(animated: false)
                this.callback?(this, false)
            }
        })
    }
    
    func add(subView: UIView, to superView: UIView) {
        superView.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["subView": subView]
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
    }
    
    @IBAction func dismissButtonClick() {
        dismiss()
    }
}
