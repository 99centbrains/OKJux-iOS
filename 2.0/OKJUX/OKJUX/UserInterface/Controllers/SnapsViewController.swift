//
//  SnapsViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit

class SnapsViewController: OKJuxViewController {

    //MARK: - Data variables
    var nearbySnaps: [Snap]?

    //MARK: - UI variables

    var collection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollection()
        fetchData()
    }

    //MARK: - Setup UI

    func setUpCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.width - 20, height: view.height - 40)
        layout.scrollDirection = .vertical
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collection.register(SnapsCollectionViewCell.self, forCellWithReuseIdentifier: SnapsCollectionViewCell.reuseIdentifier)
        collection.dataSource = self
        collection.accessibilityIdentifier = "Snaps collection"
        collection.backgroundColor = .white
        view.addSubview(collection)
    }

    //MARK: - Data manipulation

    private func fetchData() {
        showLoading(localizedMessage: R.string.localizable.loadingSnaps())
        SnapsManager.sharedInstance.getSnaps(hottest: false, completion: { (error, snapsResult) in
            self.hideLoading()
            if let error = error {
                self.showGenericErrorMessage(error: error)
            } else {
                if let snapsResult = snapsResult, snapsResult.count > 0 {
                    self.nearbySnaps = snapsResult
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

//MARK: - UICollectionViewDataSource

extension SnapsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearbySnaps?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: SnapsCollectionViewCell.reuseIdentifier,
                                                        for: indexPath) as? SnapsCollectionViewCell else {
            fatalError("unable to cast to SnapsCollectionViewCell")
        }

        cell.loadData(snap: nearbySnaps![indexPath.row])

        return cell
    }
}
