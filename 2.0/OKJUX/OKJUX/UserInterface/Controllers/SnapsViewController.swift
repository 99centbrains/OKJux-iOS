//
//  SnapsViewController.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit

class SnapsCollectionReusableView: UICollectionReusableView {
    static let reuseIdentifier = "SnapsCollectionHeaderReuseIdentifier"
}

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

        view.backgroundColor = .clear
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
        layout.headerReferenceSize = CGSize(width: view.width, height: LandingViewController.landingScreenMapHeight + LandingViewController.landingScreenSegmentHeight)
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collection.register(SnapsCollectionViewCell.self,
                            forCellWithReuseIdentifier: SnapsCollectionViewCell.reuseIdentifier)
        collection.register(SnapsCollectionReusableView.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                            withReuseIdentifier: SnapsCollectionReusableView.reuseIdentifier)
        collection.dataSource = self
        collection.delegate = self
        collection.accessibilityIdentifier = "Snaps collection " + (hottest ? "hottest" : "newest")
        collection.backgroundColor = .clear
        collection.backgroundView?.backgroundColor = .clear
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

    func collectionHeaderPressed(gesture: UITapGestureRecognizer) {
        delegate?.snapsViewControllerExpandMap(self, didPressOnHeader: gesture.view)
    }
}

// MARK: - UICollectionViewDataSource

protocol SnapsViewControllerDelegate: class {
    func snapsViewController(_ snapsViewController: SnapsViewController, isExpandingToPosition position: CGFloat)
    func snapsViewController(_ snapsViewController: SnapsViewController, didFinishExpandingToPosition position: CGFloat)
    func snapsViewControllerExpandMap(_ snapsViewController: SnapsViewController, didPressOnHeader header: UIView?)
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
        delegate?.snapsViewController(self, didFinishExpandingToPosition: -scrollView.contentOffset.y)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.snapsViewController(self, isExpandingToPosition: -scrollView.contentOffset.y)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            guard let header = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: SnapsCollectionReusableView.reuseIdentifier,
                                                                     for: indexPath) as? SnapsCollectionReusableView else {
                                                                        return UICollectionReusableView()
            }

            header.backgroundColor = .clear
            header.gestureRecognizers?.removeAll()
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(collectionHeaderPressed(gesture:))))

            return header
        }
        return UICollectionReusableView()
    }

}
