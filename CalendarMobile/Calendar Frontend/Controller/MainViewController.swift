//
//  MainViewController.swift
//  Calendar Frontend
//
//  Created by Gavi Rawson on 6/18/18.
//  Copyright © 2018 Graws Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK:  Var
    // ********************************************************************************************
    
    fileprivate struct Const {
        static let cellID = "monthCell"
        static let eventCell = "eventCell"
        static let yearFmt = "yyyy"
        static let monthFmt = "MMMM"
        static let cellFmt = "h:mm a"
        static let cellFullFmt = "h:mm a (MMM d)"
        static let loadingBatchSize = 3     // number of months to load in a batch (must be greater than 1)
    }
    
    fileprivate var eventsMapping = EventsMapping()          // data structure for table view
    fileprivate var months = [Date]()                        // months loaded into collection view (stored as first day of months)
    
    fileprivate var selectedDate: Date? { didSet { reloadTable() } }    // date selected (circled in calendar)
    
    fileprivate var todayIndex = Const.loadingBatchSize      // index for today in the months array
    fileprivate var selectedDateIndex: Int?                  // row for cell containing the selected date
    fileprivate var initialScroll = false                    // flag true if have scrolled to this month on load
    fileprivate var indexOfCellBeforeDragging = 0            // Used for calculating cell snapping
    
    fileprivate var formatter: DateFormatter = {
        let x = DateFormatter()
        x.calendar = Calendar.current
        x.timeZone = Calendar.current.timeZone
        return x
    }()
    
    fileprivate var constraints = [NSLayoutConstraint]()
    
    fileprivate var monthLabel: UILabel = { return UILabel() }()
    fileprivate var yearLabel: UILabel = { return UILabel() }()

    fileprivate var displayedDate: Date? {      // update the currently displayed date in the collection view
        didSet {
            guard let date = displayedDate else { return }
            
            // set year and month header labels
            formatter.dateFormat = Const.monthFmt
            monthLabel.set(title: formatter.string(from: date), forStyle: LabelStyle.strongTitle)
            formatter.dateFormat = Const.yearFmt
            yearLabel.set(title: formatter.string(from: date), forStyle: LabelStyle.lightTitle)
        }
    }
    
    fileprivate lazy var todayButton: UIButton = {
        let x = UIButton()
        x.addTarget(self, action: #selector(todayClicked(_:)), for: .touchUpInside)
        x.setImage(UIImage(named: "today")?.withRenderingMode(.alwaysTemplate), for: .normal)
        x.tintColor = Colors.tint
        return x
    }()
    
    fileprivate lazy var refreshButton: UIButton = {
        let x = UIButton()
        x.addTarget(self, action: #selector(refreshClicked(_:)), for: .touchUpInside)
        x.setImage(UIImage(named: "refresh")?.withRenderingMode(.alwaysTemplate), for: .normal)
        x.tintColor = Colors.tint
        return x
    }()
    
    fileprivate var separator: UIView = {
        let x = UIView()
        x.backgroundColor = Colors.separator
        return x
    }()
    
    fileprivate var addEventButton: UIButton = {
        let x = UIButton()
        x.setImage(UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        x.tintColor = Colors.tint
        x.addTarget(self, action: #selector(addEventClicked(_:)), for: .touchUpInside)
        return x
    }()
    
    fileprivate var dayLabels: UIStackView = {
        let x = UIStackView()
        x.axis = .horizontal
        x.distribution = .equalCentering
        
        // Day labels
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        for day in days {
            let label = UILabel()
            label.set(title: day, forStyle: LabelStyle.fadedRegular)
            x.addArrangedSubview(label)
        }

        return x
    }()
    
    lazy fileprivate var eventsTableView: UITableView = {
        let x = UITableView(frame: .zero, style: .plain)
        x.backgroundColor = Colors.blue3
        x.separatorColor = Colors.separator
        x.register(EventTableViewCell.self, forCellReuseIdentifier: Const.eventCell)
        x.estimatedRowHeight = UITableViewAutomaticDimension
        x.tableFooterView = UIView()
        
        // shadow
        x.layer.shadowColor = UIColor.black.cgColor
        x.layer.shadowOpacity = 0.15
        x.layer.shadowOffset = .zero
        x.layer.shadowRadius = 5
        return x
    }()
    
    fileprivate var emptyTableLabel: UILabel = {
        let x = UILabel()
        x.set(title: "No Events", forStyle: LabelStyle.fadedHeader)
        return x
    }()
    
    fileprivate var monthCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.5

        let x = UICollectionView(frame: .zero, collectionViewLayout: layout)
        x.backgroundColor = Colors.separator
        x.clipsToBounds = false
        x.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: Const.cellID)
        x.showsHorizontalScrollIndicator = false
        return x
    }()
    
    
    // MARK:  Life Cycle
    // ********************************************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        updateLayout()
        initMonths()

        displayedDate = months[todayIndex]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // collection view sizing
        let layout = monthCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width, height: monthCollectionView.frame.height)
        
        // scroll to today on load
        if !initialScroll {
            monthCollectionView.scrollToItem(at: IndexPath(row: todayIndex, section: 0), at: .centeredHorizontally, animated: false)
            initialScroll = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent   // Make light status bar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let index = eventsTableView.indexPathForSelectedRow {
            eventsTableView.deselectRow(at: index, animated: true)
        }
    }
    
    // MARK:  Func
    // ********************************************************************************************
    
    // refresh the events
    fileprivate func refresh() {
        guard let first = months.first, let last = months.last else { return }
        eventsMapping.clear()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        eventsMapping.loadEvents(start: first, end: last) { [weak self] (success) in
            guard success else {
                self?.presentAlertWith("Failed to load events.")
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.reloadCollectionView()    // TODO: Innefficient to reload all cells
                self?.reloadTable()
            }
        }
    }
    
    fileprivate func presentAlertWith(_ msg: String) {
        let alert = UIAlertController(title: "Uh Oh", message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // Initialize the initial months in the collection view
    fileprivate func initMonths() {
        let offset = Const.loadingBatchSize
        for i in -offset...offset {
            let startOfMonth = Calendar.current.date(byAdding: DateComponents(month: i, day: 0), to: Date())!.startOfMonth()
            months.append(startOfMonth)
        }
        
        // load events
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let last = Calendar.current.date(byAdding: DateComponents(day: 1), to: months.last!)!
        eventsMapping.loadEvents(start: months.first!, end: last) { [weak self] (success) in
            guard success else {
                self?.presentAlertWith("Failed to load events.")
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.reloadCollectionView()
                self?.reloadTable()
            }
        }
    }
    
    fileprivate func initViews() {
        view.backgroundColor = Colors.blue1
        
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        
        let views = [
            monthCollectionView, monthLabel, yearLabel, eventsTableView, emptyTableLabel, addEventButton, dayLabels,
            separator, todayButton, refreshButton
        ]
        
        views.forEach { view.addSubview($0) }
    }
    
    fileprivate func updateLayout() {
        view.removeConstraints(constraints)
        constraints = []
        
        let views = [
            monthCollectionView, monthLabel, yearLabel,     // 0-2
            eventsTableView, addEventButton, dayLabels,     // 3-5
            separator, todayButton, refreshButton           // 6-8
        ]
        
        let metrics = [Layout.margin, 20, Layout.margin*2, Layout.margin*1.5]
        let formats = [
            "H:|[v0]|",
            "H:|-(m0)-[v1]-[v2]",
            "V:|-(40)-[v1]-(m0)-[v5]-(m0)-[v6(0.5)]-[v0(275)]-[v3]|",
            "H:|[v3]|",
            "H:|-(m3)-[v5]-(m3)-|",
            "H:|-[v6]-|",
            "H:[v8]-(m3)-[v7]-(m3)-[v4(m1)]-|",
            "V:[v4(m1)]"
        ]
        
        constraints = view.createConstraints(withFormats: formats, metrics: metrics, views: views)
        
        emptyTableLabel.translatesAutoresizingMaskIntoConstraints = false
        
        constraints += [
            yearLabel.lastBaselineAnchor.constraint(equalTo: monthLabel.lastBaselineAnchor),
            emptyTableLabel.centerXAnchor.constraint(equalTo: eventsTableView.centerXAnchor),
            emptyTableLabel.centerYAnchor.constraint(equalTo: eventsTableView.centerYAnchor),
//            yearLabel.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -Layout.margin),
            addEventButton.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            todayButton.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            refreshButton.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor)
        ]
        
        view.addConstraints(constraints)
    }
    
    // Index of the most visible cell on screen
    fileprivate func indexOfMajorCell() -> Int {
        let layout = monthCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = layout.itemSize.width
        let proportionalOffset = monthCollectionView.contentOffset.x / itemWidth
        return Int(round(proportionalOffset))
    }
    
    // reload the events table view
    fileprivate func reloadTable() {
        emptyTableLabel.isHidden = eventsMapping.countEventsFor(selectedDate) > 0
        eventsMapping.sortEventsFor(selectedDate)   // only sort displayed events for efficiency sake
        eventsTableView.reloadData()
    }
    
    // reload the collection view
    fileprivate func reloadCollectionView() {
        monthCollectionView.reloadData()
    }
    
    // show event details form
    fileprivate func showEventDetails(_ forEvent: Event?) {
        let vc = EventDetailsViewController()
        vc.delegate = self
        vc.editEvent = forEvent
        vc.selectedDate = selectedDate
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    // MARK:  Event listener
    // ********************************************************************************************
    
    @objc fileprivate func refreshClicked(_ sender: UIButton) {
        refresh()
    }
    
    @objc fileprivate func addEventClicked(_ sender: UIButton) {
        showEventDetails(nil)
    }
    
    @objc fileprivate func todayClicked(_ sender: UIButton) {
        monthCollectionView.scrollToItem(at: IndexPath(row: todayIndex, section: 0), at: .centeredHorizontally, animated: true)
        displayedDate = months[todayIndex]
    }
}


// MARK: Collection view data source
// ********************************************************************************************

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.cellID, for: indexPath) as! MonthCollectionViewCell
        cell.eventsMapping = eventsMapping  
        cell.date = months[indexPath.row]
        cell.delegate = self
        cell.selectedDate = indexPath.row == selectedDateIndex ? selectedDate : nil
        cell.update()
        return cell
    }
}

// MARK: Collection view delegate
// ********************************************************************************************

extension MainViewController: UICollectionViewDelegateFlowLayout {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset   // Stop scrollView sliding
        let indexOfMajorCell = self.indexOfMajorCell()           // calculate where scrollView should snap to
        
        // calculate conditions for snapping
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < months.count && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        // Snap to cell
        let snapToIndex = didUseSwipeToSkipCell ? indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1) : indexOfMajorCell
        monthCollectionView.scrollToItem(at: IndexPath(row: snapToIndex, section: 0), at: .centeredHorizontally, animated: true)

        // Update header labels for year and month if displaying a new cell
        if snapToIndex != indexOfCellBeforeDragging {
            displayedDate = months[snapToIndex]
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let indexOfMajorCell = self.indexOfMajorCell()                                      // Currently displayed cell index
        let monthsNeedUpdate = indexOfMajorCell <= 2 || indexOfMajorCell >= months.count-3  // Need to load new months
        let updateBeginning = monthsNeedUpdate && indexOfMajorCell <= 2                     // update beginning of months array

        if monthsNeedUpdate {

            // Load batch of months
            for _ in 0..<Const.loadingBatchSize {
                let referenceDate = updateBeginning ? months.first! : months.last!
                let toAdd = Calendar.current.date(byAdding: DateComponents(month: updateBeginning ? -1 : 1, day: 0), to: referenceDate)!.startOfMonth()
                updateBeginning ? months.insert(toAdd, at: 0) : months.append(toAdd)
                if updateBeginning {
                    todayIndex += 1
                    if selectedDateIndex != nil { selectedDateIndex! += 1 }
                }
            }
            
            // reload view
            if updateBeginning {
                reloadCollectionView()    // TODO: Innefficient to reload all cells
                monthCollectionView.scrollToItem(at: IndexPath(row:indexOfMajorCell+Const.loadingBatchSize, section: 0), at: .centeredHorizontally, animated: false)
            }
            
            // Load events for new months
            let firstMonth = months[updateBeginning ? 0 : months.count-2  - (Const.loadingBatchSize-1)].startOfMonth()
            var lastMonth = months[updateBeginning ? Const.loadingBatchSize-1 : (months.count-1)].endOfMonth()
            lastMonth = Calendar.current.date(byAdding: DateComponents(day: 1), to: lastMonth)!
    
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            eventsMapping.loadEvents(start: firstMonth, end: lastMonth) { [weak self] (success) in
                guard success else {
                    self?.presentAlertWith("Failed to load events.")
                    return
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self?.reloadCollectionView()    // TODO: Innefficient to reload all cells
                    self?.reloadTable()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! MonthCollectionViewCell
        guard
            let oldDate = cell.date,
            let newDate = displayedDate
        else { return }

        // check this is not the currently displayed cell
        let oldComp = Calendar.current.dateComponents([.year, .month], from: oldDate)
        let newComp = Calendar.current.dateComponents([.year, .month], from: newDate)
        guard oldComp != newComp else { return }

        // clear selected day
        cell.clearSelectedDay()
        selectedDate = nil
    }
}

// MARK:  Table view data source
// ********************************************************************************************

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsMapping.countEventsFor(selectedDate)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.eventCell, for: indexPath as IndexPath) as! EventTableViewCell
        
        // selection color
        let selection = UIView()
        selection.backgroundColor = Colors.blue4
        cell.selectedBackgroundView = selection
        
        guard let event = eventsMapping.eventFor(selectedDate, atRow: indexPath.row) else { return cell }
        cell.title = event.title
        
        formatter.dateFormat = Const.cellFmt
        cell.start = formatter.string(from: event.startDate)
        
        // handles label for multi-day events
        if !Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate) {
            formatter.dateFormat = Const.cellFullFmt
        }
        
        cell.end = formatter.string(from: event.endDate)
        return cell
    }
}

// MARK:  UI Table view delegate
// ********************************************************************************************

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let event = eventsMapping.eventFor(selectedDate, atRow: indexPath.row) else { return }
        showEventDetails(event)
    }
}


// MARK:  Month Collection view cell delegate
// ********************************************************************************************

extension MainViewController: MonthCollectionViewCellDelegate {
    func didSelect(date: Date) {
       selectedDate = date
        
        // store index for selected cell
        let paths = monthCollectionView.indexPathsForVisibleItems
        selectedDateIndex = paths.first?.row
    }
}

// MARK:  Event form delegate
// ********************************************************************************************

extension MainViewController: EventFormDelegate {
   
    func didEdit(_ oldEvent: Event, newEvent: Event) {
        eventsMapping.remove(oldEvent)
        eventsMapping.add(newEvent)
        reloadIndexPathsFor(oldEvent)
        reloadIndexPathsFor(newEvent)
    }
    
    func didCreate(_ event: Event) {
        eventsMapping.add(event)
        reloadIndexPathsFor(event)
    }
    
    func didDelete(_ event: Event) {
        eventsMapping.remove(event)
        reloadIndexPathsFor(event)
    }

    // reload the month and adjacent months for a specified event
    fileprivate func reloadIndexPathsFor(_ event: Event) {
        
        // difference in months between today and event
        let monthDiff = Calendar.current.dateComponents([.month], from: Date(), to: event.endDate).month!
        let monthIndex = todayIndex + monthDiff
        
        // calculate indices of months
        var toReload = [IndexPath]()
        toReload.append(IndexPath(row: monthIndex, section: 0))                                          // month for event
        if monthIndex-1 >= 0 {              toReload.append(IndexPath(row: monthIndex-1, section: 0)) }  // month earlier
        if monthIndex+1 < months.count {    toReload.append(IndexPath(row: monthIndex+1, section: 0)) }  // month later
        
        // reload
        monthCollectionView.reloadItems(at: toReload)
        reloadTable()
    }
}



