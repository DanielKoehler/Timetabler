//
//  TTPageViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 13/11/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit

class TTPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        for view in self.view.subviews as [UIView]  {
            
            if (view.isKindOfClass(NSClassFromString("_UIQueuingScrollView"))) {
            
                var frame = view.frame
                frame.size.height = view.superview!.frame.size.height
                view.frame = frame

            }
        }
        
        
        
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        self.pageController.dataSource = self;
        // We need to cover all the control by making the frame taller (+ 37)
        [[self.pageController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
        
        TutorialPageViewController *initialViewController = [self viewControllerAtIndex:0];
        
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        [self addChildViewController:self.pageController];
        [[self view] addSubview:[self.pageController view]];
        [self.pageController didMoveToParentViewController:self];
        
        // Bring the common controls to the foreground (they were hidden since the frame is taller)
        [self.view bringSubviewToFront:self.pcDots];
        [self.view bringSubviewToFront:self.btnSkip];
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
