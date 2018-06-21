import UIKit
import DatePickerDialog

class DatePickerTableViewCell: UITableViewCell {
    
    // MARK:  Var
    // ********************************************************************************************
    
    var selectedDate: Date? { didSet { updateDate() } }
    var directions: String? { didSet { titleLabel.set(title: directions, forStyle: LabelStyle.subtitle) } }
    
    fileprivate var c = [NSLayoutConstraint]()
    
    fileprivate var titleLabel: UILabel = {
        let x = UILabel()
        return x
    }()
    
    lazy fileprivate var pickerButton: UIButton = {
        let x = UIButton()
        x.set(title: "Select", states: [.normal], forStyle: LabelStyle.button)
        x.addTarget(self, action: #selector(pickerTapped(_:)), for: .touchUpInside)
        return x
    }()
    
    fileprivate var formatter: DateFormatter = {
        let x = DateFormatter()
        x.dateFormat = "MMM d, yyyy h:mm a"
        return x
    }()
    
    fileprivate var datePicker: DatePickerDialog = {
        return DatePickerDialog(textColor: Colors.blue1, buttonColor: Colors.tint, font: UIFont.systemFont(ofSize: 15), locale: Locale.current, showCancelButton: true)
    }()
    
    // MARK:  Init
    // ********************************************************************************************
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        updateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:  Func
    // ********************************************************************************************
    
    
    fileprivate func initViews() {
        backgroundColor = Colors.blue3
        addSubview(pickerButton)
        addSubview(titleLabel)
    }
    
    fileprivate func updateLayout() {
        removeConstraints(c)
        c = []
        
        let views = [ pickerButton, titleLabel ]
        let metrics = [ Layout.margin ]
        let formats = [
            "H:[v0]-(m0)-|",
            "V:|-(m0)-[v1]-(m0)-|",
            "H:|-(m0)-[v1]"
        ]
        
        c = createConstraints(withFormats: formats, metrics: metrics, views: views)
        
        c += [
            pickerButton.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: pickerButton.leadingAnchor, constant: -Layout.margin)
        ]
        
        addConstraints(c)
    }
    
    fileprivate func updateDate() {
        guard let date = selectedDate else { return }
        pickerButton.set(title: formatter.string(from: date), states: [.normal], forStyle: LabelStyle.button)
    }
    
    // MARK: event listeners
    // ********************************************************************************************
    
    @objc fileprivate func pickerTapped(_ sender: UIButton) {
        datePicker.show(
            titleLabel.text ?? "", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: selectedDate ?? Date(),
            minimumDate: nil, maximumDate: nil, datePickerMode: .dateAndTime) { [weak self] (date) -> Void in
            
            guard let date = date else { return }
            
            // Clear seconds
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            self?.selectedDate = Calendar.current.date(from: components)!
            self?.selectedDate = date
        }
    }
}
