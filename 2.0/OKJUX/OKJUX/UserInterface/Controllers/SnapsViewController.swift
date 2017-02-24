//
//  SnapsViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit

class SnapsViewController: OKJuxViewController {

    // MARK: - Data variables

    var nearbySnaps: [Snap]?
    var hottest: Bool = false
    weak var delegate: SnapsViewControllerDelegate?

    // MARK: - UI variables

    var collection: UICollectionView!

    // MARK: - Controller life cycle

    init(hottest: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.hottest = hottest
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollection()
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collection.frame = view.bounds
    }

    // MARK: - Setup UI

    func setUpCollection() {
        let layout = UICollectionViewFlowLayout()
        if hottest {
            layout.itemSize = CGSize(width: view.width / 2 - 15, height: view.width / 2 - 15)
        } else {
            layout.itemSize = CGSize(width: view.width - 20, height: view.height - 40)
        }
        layout.scrollDirection = .vertical
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collection.register(SnapsCollectionViewCell.self, forCellWithReuseIdentifier: SnapsCollectionViewCell.reuseIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.accessibilityIdentifier = "Snaps collection " + (hottest ? "hottest" : "newest")
        collection.backgroundColor = .white
        view.addSubview(collection)
    }

    // MARK: - Data manipulation

    private func fetchData() {
        showLoading(localizedMessage: R.string.localizable.loadingSnaps())
        SnapsManager.sharedInstance.getSnaps(hottest: hottest, completion: { (error, snapsResult) in
            self.hideLoading()
            if let error = error {
                self.showGenericErrorMessage(error: error)
            } else {
                if let snapsResult = snapsResult, !snapsResult.isEmpty {
                    self.nearbySnaps = snapsResult
                    if let nearbySnaps = self.nearbySnaps {
                        self.delegate?.snapsViewController(self, updatedSnapsList: nearbySnaps)
                    }
                    self.reloadData()
                    return

                }
                self.showGenericErrorMessage(error: nil)
            }
        })
    }

    func reloadData() {
        collection.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

protocol SnapsViewControllerDelegate: class {
    func snapsViewController(_ snapsViewController: SnapsViewController, hasBeenExpandedToPosition position: CGFloat)
    func snapsViewController(_ snapsViewController: SnapsViewController, updatedSnapsList snaps: [Snap])
}

extension SnapsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbySnaps?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: SnapsCollectionViewCell.reuseIdentifier,
                                                        for: indexPath) as? SnapsCollectionViewCell else {
            fatalError("unable to cast to SnapsCollectionViewCell")
        }

        cell.loadData(snap: nearbySnaps![indexPath.row], hottest: hottest)

        return cell
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.snapsViewController(self, hasBeenExpandedToPosition: -scrollView.contentOffset.y)
    }

}
