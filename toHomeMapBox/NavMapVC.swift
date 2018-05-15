//
//  ViewController.swift
//  toHomeMapBox
//
//  Created by Kristyan Danailov on 13.05.18 г..
//  Copyright © 2018 г. Kristyan Danailov. All rights reserved.
//

import UIKit

import Mapbox
import MapboxCoreNavigation
import MapboxDirections
import MapboxNavigation

import UIKit.UIGestureRecognizerSubclass

private enum State {
    case closed
    case open
}
extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}
@IBDesignable
class NavMapVC: UIViewController, MGLMapViewDelegate {
    var mapView: NavigationMapView!
    var directionsRoute: Route?
    
    var homeLocation = CLLocationCoordinate2D()
    var newHomeLocation = CLLocationCoordinate2D()
    var disneyLocation = CLLocationCoordinate2DMake(37.8014548, -122.4586558)
    
    
    private let popupOffset: CGFloat = 440
    private let offset: CGFloat = 150
    
    private var bottomConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.none, animated: false)
        mapView.layoutSubviews()
        view.addSubview(mapView)
        
        //let myHomeDestination = loadCoordinates()
        layout()
        
        /// Load Gesture Recognizers
        littleView.addGestureRecognizer(littlepanRecognizer)
        popupView.addGestureRecognizer(panRecognizer)
        setHomeButton.addGestureRecognizer(setHomeRecognizer)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        whiteView.addSubview(welcomeLbl)
        UIView.animate(withDuration: 2) {
            self.welcomeLbl.alpha = 1
            self.welcomeLbl.transform = (CGAffineTransform(translationX: 0, y: -150))
        }
    }
    
    
    
    // Views
    private lazy var houseImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "home")
        imageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var navigationImg: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: (toHomeButton.frame.width/2) - 40, y: (toHomeButton.frame.height/2) - 40, width: 80, height: 80))
        imageView.image = #imageLiteral(resourceName: "navigation")
        imageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowColor = UIColor.white.cgColor
        return imageView
    }()
    
    private lazy var popupView: GradientView = {
        let view = GradientView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20.0
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    private lazy var whiteView: GradientView = {
        let view = GradientView ()
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 20.0
        view.alpha = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var littleView: UIRoundedButtonWithGradientAndShadow = {
        let view = UIRoundedButtonWithGradientAndShadow(gradientColors: [#colorLiteral(red: 0.9764705882, green: 0.8509803922, blue: 0.5490196078, alpha: 1) ,#colorLiteral(red: 0.2392156863, green: 0.662745098, blue: 0.9764705882, alpha: 1) ])
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        view.alpha = 1
        view.layer.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    
    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set My Home"
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set My Home"
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.heavy)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    
    private lazy var navigateHomeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (view.frame.width/2) + 60, y: view.frame.height + 135, width:80, height: 80))
        button.setTitle("GO", for: .normal)
        button.alpha = 0
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.3
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(calloutNavigationView), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var setHomeButton: UIButton!  = {
        let newbutton = UIButton()
        newbutton.setTitle("Set Your Position as Home", for: .normal)
        newbutton.layer.cornerRadius = 20.0
        newbutton.clipsToBounds = true
        newbutton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        newbutton.layer.shadowOpacity = 0.1
        newbutton.layer.shadowRadius = 0.4
        newbutton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        newbutton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 18)
        newbutton.showsTouchWhenHighlighted = true
        newbutton.addTarget(self, action: #selector(setNewHome), for: .touchUpInside)
        return newbutton
    }()
    
    
    private lazy var welcomeLbl: UILabel = {
        let welcomeLbl = UILabel(frame: CGRect(x: (view.frame.width/2) - 125, y: (view.frame.height/2) + 320, width: 350, height: 250))
        welcomeLbl.text = "\"A man travels the world over in search of what he needs, and returns home to find it.\""
        welcomeLbl.numberOfLines = 0
        welcomeLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        welcomeLbl.textAlignment = .natural
        welcomeLbl.alpha = 0
        welcomeLbl.font = UIFont(name: "AvenirNext-UltraLight", size: 28)

        return welcomeLbl
    }()
    
    private lazy var toHomeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: (view.frame.width/2) - 100, y: (view.frame.height/2) - 100, width: 200, height: 200))
        button.setTitle(" ", for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        button.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 0.4
        button.layer.masksToBounds = false
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 30)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(takeMeHome), for: .touchUpInside)
  
        button.isUserInteractionEnabled = true
        button.isEnabled = true
        
        let pulse1 = CASpringAnimation(keyPath: "transform.scale")
        pulse1.duration = 2
        pulse1.fromValue = 1.0
        pulse1.toValue = 1.2
        pulse1.autoreverses = true
        pulse1.repeatCount = 0
        pulse1.initialVelocity = 10
        pulse1.damping = 9
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 6
        animationGroup.repeatCount = 1000
        animationGroup.animations = [pulse1]
        
        button.layer.add(animationGroup, forKey: "pulse")
        
        return button
    }()

    func layout() {
        
        littleView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(littleView)
        littleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -15).isActive = true
        bottomConstraint = littleView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        bottomConstraint.isActive = true
        littleView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        littleView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        houseImg.translatesAutoresizingMaskIntoConstraints = false
        littleView.addSubview(houseImg)
        houseImg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: +10).isActive = true
        bottomConstraint = houseImg.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35)
        bottomConstraint.isActive = true
        houseImg.heightAnchor.constraint(equalToConstant: 40).isActive = true
        houseImg.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(whiteView)
        whiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -50).isActive = true
        whiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: +50).isActive = true
        bottomConstraint = whiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        whiteView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50).isActive = true

        
        mapView.addSubview(toHomeButton)
        toHomeButton.addSubview(navigationImg)
        mapView.addSubview(navigateHomeButton)
       
        setHomeButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(setHomeButton)
        setHomeButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 60).isActive = true
        setHomeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -60).isActive = true
        setHomeButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -370).isActive = true
        setHomeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.alpha = 0
        popupView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30).isActive = true
        
    }
  
    
    func calculateRoute(from originCoor:CLLocationCoordinate2D, to destinationCoor: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void) {
        let myHomeDestination = loadCoordinates()
        let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -10, name: "Start")
        let destination = Waypoint(coordinate: myHomeDestination![0], coordinateAccuracy: -1, name: "Finish")
        let options = NavigationRouteOptions(waypoints: [origin,destination], profileIdentifier: .automobileAvoidingTraffic )
        
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, route, error) in
            self.directionsRoute = route?.first
            self.drawLine(route: (self.directionsRoute!))
            
            let coordinateBounds = MGLCoordinateBounds(sw: destinationCoor, ne: originCoor)
            let insets = UIEdgeInsetsMake(50, 50, 50, 50)
            let followCamera = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
            self.mapView.setCamera(followCamera, animated: true)
        })
    }
    
    func drawLine(route: Route) {
        guard route.coordinateCount > 0 else {return}
        var routeCoordinates = route.coordinates!
        let polyLine = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyLine
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyLine], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 7.0)
            
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    
        @objc func setNewHome(sender: UIButton!) {
            newHomeLocation = (mapView.userLocation?.coordinate)!
            storeCoordinates([newHomeLocation])
        }

    func storeCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        let locations = coordinates.map { coordinate -> CLLocation in
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        let archived = NSKeyedArchiver.archivedData(withRootObject: locations)
        UserDefaults.standard.set(archived, forKey: "coordinates")
        UserDefaults.standard.synchronize()
    }
    
    func loadCoordinates() -> [CLLocationCoordinate2D]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = NSKeyedUnarchiver.unarchiveObject(with: archived) as? [CLLocation] else {
                return nil
        }
        
        let coordinates = locations.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        return coordinates
}
    
    @objc func takeMeHome(sender: UIButton!) {

        UIView.animate(withDuration: 1,
                       animations: {
                        self.whiteView.alpha = 0
                        self.navigateHomeButton.alpha = 0.6
                        self.toHomeButton.transform = (CGAffineTransform(translationX: 0, y: +300))
                        self.toHomeButton.alpha = 0
                        self.welcomeLbl.transform = (CGAffineTransform(translationX: 0, y: -200))
                        self.welcomeLbl.alpha = 0
        },
                       completion: { _ in
                        UIView.animate(withDuration: 1) {
                            self.whiteView.alpha = 0
                            self.navigateHomeButton.alpha = 1
                            self.navigateHomeButton.transform = (CGAffineTransform(translationX: 0, y: -240))
        }
        })
        
        ////////////////////////
        
        let myHomeDestination = loadCoordinates()
        let currentLocation = mapView.userLocation!.coordinate
        if myHomeDestination?.isEmpty == false {
            calculateRoute(from: currentLocation, to: myHomeDestination![0]) { (route, error) in
                if error != nil {
                    print("Error occured")
                }
            }
        } else {
            let center = mapView.userLocation!.coordinate
            
            // Optionally set a starting point.
            mapView.setCenter(center, zoomLevel: 1, direction: 0, animated: false)
            let camera = MGLMapCamera(lookingAtCenter: mapView.centerCoordinate, fromDistance: 4500, pitch: 15, heading: 180)
            
            // Animate the camera movement over 5 seconds.
            mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }

    @objc func calloutNavigationView(){
        let myHomeDestination = loadCoordinates()
        if myHomeDestination?.isEmpty == false {
            let navigateToRoute = self.directionsRoute!
            let navigationVC = NavigationViewController(for: navigateToRoute)
            self.present(navigationVC , animated: true, completion: nil)
        }
        let noHome = NoHomeModalVC()
        noHome.modalPresentationStyle = .custom
        present(noHome, animated: true, completion: nil)
        }

    /// Pan Animation
    // MARK: - Animation
    
    /// The current state of the animation. This variable is changed only when an animation completes.
    private var currentState: State = .closed
    
    /// All of the currently running animators.
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    /// The progress of each animator. This array is parallel to the `runningAnimators` array.
    private var animationProgress = [CGFloat]()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    private lazy var littlepanRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    private lazy var setHomeRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(setNewHome(sender:)))
        return recognizer
    }()
    
    
    /// Animates the transition, if the animation is not already running.
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        // ensure that the animators array is empty (which implies new animations need to be created)
        guard runningAnimators.isEmpty else { return }
        
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 280
                self.popupView.layer.cornerRadius = 20
                self.popupView.alpha = 1
                self.overlayView.alpha = 0.5
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
            case .closed:
                
                
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.popupView.alpha = 0
                self.overlayView.alpha = 0
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
            }
            self.view.layoutIfNeeded()
        })
        
        // the transition completion block
        transitionAnimator.addCompletion { position in
            
            // update the state
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            
            // manually reset the constraint positions
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 280
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                
            }
            
            // remove all running animators
            self.runningAnimators.removeAll()
            
        }
        
        // an animator for the title that is transitioning into view
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
            switch state {
            case .open:
                self.openTitleLabel.alpha = 1
            case .closed:
                self.closedTitleLabel.alpha = 1
            }
        })
        inTitleAnimator.scrubsLinearly = false
        
        // an animator for the title that is transitioning out of view
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            switch state {
            case .open:
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.openTitleLabel.alpha = 0
            }
        })
        outTitleAnimator.scrubsLinearly = false
        
        // start all animators
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
        
        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
        
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            // start the animations
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            
            // pause all animations, since the next event may be a pan changed
            runningAnimators.forEach { $0.pauseAnimation() }
            
            // keep track of each animator's progress
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            // variable setup
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            
            // adjust the fraction for the current state and reversed state
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            // apply the new fraction
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            // variable setup
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            
            // if there is no motion, continue all animations and exit early
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            // reverse the animations based on their current state and pan motion
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            
            // continue all animations
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            ()
        }
    }
}
class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
    }
    
}

