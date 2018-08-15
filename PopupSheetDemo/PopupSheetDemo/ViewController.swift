//
//  ViewController.swift
//  PopupSheetDemo
//
//  Created by Chai on 2018/3/15.
//  Copyright © 2018年 FYH. All rights reserved.
//

import UIKit
import PopupSheet

class ViewController: UIViewController {

    var strongPsvc: PopupSheetViewController?

    func viewContent() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.backgroundColor = UIColor.red
        return view
    }
    
    func viewControllerContent() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "B")
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        var psvc: PopupSheetViewController!
        
        switch sender.tag {
        case 1:
            psvc = PopupSheetViewController.newInstance(withContent: viewContent(), direction: .up)
            psvc.offsetView = sender
        case 2:
            psvc = PopupSheetViewController.newInstance(withContent: viewContent(), direction: .down)
            psvc.offsetView = sender
        case 3:
            psvc = PopupSheetViewController.newInstance(withContent: viewContent(), direction: .left)
        case 4:
            psvc = PopupSheetViewController.newInstance(withContent: viewContent(), direction: .right)
            psvc.offset = 60
        case 5:
            if self.strongPsvc == nil {
                self.strongPsvc = PopupSheetViewController.newInstance(withContent: viewControllerContent(), direction: .up)
            }
            psvc = self.strongPsvc
            psvc.displayLength = 280
        default:
            psvc = PopupSheetViewController.newInstance(withContent: viewContent(), direction: .down)
            psvc.offsetView = self.navigationController?.navigationBar
        }
        
        psvc.callback = { (vc, isShow) in
            print(vc, isShow)
        }
        psvc.show(in: self)
    }
}
