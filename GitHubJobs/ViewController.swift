import UIKit
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SFSafariViewControllerDelegate
{
   
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    var jobResults = [Jobs]()
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dev Jobs"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupTableView()
        setupSearchBar()
        loadData()
    }

    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.placeholder = "Search by job title"
    }

    func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let position = searchController.searchBar.text {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
                Service.shared.getResults(description: position) {[weak self] result in
                    switch result {
                    case .success(let results):
                        print(results)
                        self?.jobResults = results
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            let alertPopUp = UIAlertController(title: error.rawValue, message: nil, preferredStyle: .alert)
                            alertPopUp.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(alertPopUp, animated: true)
                        }
                        print(error)
                    }
                }
            })
        }
    }
    
    func loadData() {
        timer?.invalidate()
        let searchText = searchController.searchBar.text
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            Service.shared.getResults(description: searchText!) { [weak self] result in
                switch result {
                case .success(let results):
                    print(results)
                    self?.jobResults = results
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: error.rawValue, message: nil, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                    print(error)
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobResults.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let safariVC = SFSafariViewController(url: NSURL(string: jobResults[indexPath.row].url!)! as URL)
        present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "\(jobResults[indexPath.row].title) - \(jobResults[indexPath.row].company) - \(jobResults[indexPath.row].location ?? "")"
        cell.textLabel?.numberOfLines = -1
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.text = jobResults[indexPath.row].createdAt
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
}
