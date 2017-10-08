//
//  CollectionViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public enum UICollectionElementKindSection: String {

    case header = "UICollectionElementKindSectionHeader"
    case footer = "UICollectionElementKindSectionFooter"

}

public protocol _SectionPartionCollectionViewProvider {

    var identity: String { get }
    var cellType: UICollectionReusableView.Type { get }
    var collectionElementKindSection: UICollectionElementKindSection { get }

    func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node)

    func _genteralSectionPartion() -> Observable<_Node?>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize?
    
}

extension _SectionPartionCollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(self.cellType, forSupplementaryViewOfKind: self.collectionElementKindSection.rawValue, withReuseIdentifier: self.identity)
    }
    
}

public protocol SectionPartionCollectionViewProvider: _SectionPartionCollectionViewProvider {
    
    associatedtype Cell: UICollectionReusableView
    associatedtype Value
    
    func configureSupplementaryView(_ collectionView: UICollectionView, sectionView: Cell, indexPath: IndexPath, value: Value)
    
    func genteralSectionPartion() -> Observable<Value?>
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize?
    
}

extension SectionPartionCollectionViewProvider {
    
    public var cellType: UICollectionReusableView.Type { return Cell.self }
    
    public func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<Value> {
            configureSupplementaryView(collectionView, sectionView: sectionView as! Cell, indexPath: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _genteralSectionPartion() -> Observable<_Node?> {
        let providerIdentity = self.identity
        return genteralSectionPartion().map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize? {
        if let valueNode = node as? ValueNode<Value> {
            return self.collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize? {
        return nil
    }
    
}

public typealias _AnimatableSectionPartionCollectionViewProvider = _AnimatableSectionPartionProviderable & _SectionPartionCollectionViewProvider

public protocol AnimatableSectionPartionCollectionViewProvider: SectionPartionCollectionViewProvider, _AnimatableSectionPartionProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func genteralAnimatableSection() -> Observable<IdentifiableNode?>
    
}

extension AnimatableSectionPartionCollectionViewProvider {
    
    public func _genteralAnimatableSectionPartion() -> Observable<IdentifiableNode?> {
        return genteralAnimatableSection()
    }
    
}

extension AnimatableSectionPartionCollectionViewProvider {
    
    public func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            configureSupplementaryView(collectionView, sectionView: sectionView as! Cell, indexPath: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize? {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize? {
        return nil
    }
    
    public func genteralAnimatableSection() -> Observable<IdentifiableNode?> {
        let providerIdentity = self.identity
        return genteralSectionPartion()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }
    
}
