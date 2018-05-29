//
//  LambdaTableView.swift
//  HogeApp
//
//  Created by yoshi on 2018/02/27.
//  Copyright © 2018年 yoshi. All rights reserved.
//

import UIKit

class LambdaTableView: UITableView,
                       UITableViewDelegate,
                       UITableViewDataSource,
                       UIScrollViewDelegate {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
       }
    
    /** UITableViewDelegate */
    var delegateHeightRowAt: ((IndexPath) -> CGFloat)?
    var delegateEstimatedHeightForRowAt: ((IndexPath) -> CGFloat)?
    var delegateIndentationLevelForRowAt: ((IndexPath) -> Int)?
    var delegateWillDisplay: ((UITableViewCell,IndexPath) -> Void)?
    var delegateEditActionsForRowAt: ((IndexPath) -> [UITableViewRowAction]?)?
    var delegateAccessoryButtonTappedForRowWith: ((IndexPath) -> Void)?
    var delegateWillSelectRowAt: ((IndexPath) -> IndexPath?)?
    var delegateDidSelectRowAt: ((IndexPath) -> Void)?
    var delegateWillDeselectRowAt: ((IndexPath) -> IndexPath?)?
    var delegateDidDeselectRowAt: ((IndexPath) -> Void)?
    var delegateViewForHeaderInSection: ((Int) -> UIView?)?
    var delegateViewForFooterInSection: ((Int) -> UIView?)?
    var delegateHeightForHeaderInSection: ((Int) -> CGFloat)?
    var delegateEstimatedHeightForHeaderInSection: ((Int) -> CGFloat)?
    var delegateHeightForFooterInSection: ((Int) -> CGFloat)?
    var delegateEstimatedHeightForFooterInSection: ((Int) -> CGFloat)?
    var delegateWillDisplayHeaderView: ((UIView,Int) -> Void)?
    var delegateWillDisplayFooterView: ((UIView,Int) -> Void)?
    var delegateWillBeginEditingRowAt: ((IndexPath) -> Void)?
    var delegateDidEndEditingRowAt: ((IndexPath?) -> Void)?
    var delegateEditingStyleForRowAt: ((IndexPath) -> UITableViewCellEditingStyle)?
    var delegateTitleForDeleteConfirmationButtonForRowAt: ((IndexPath) -> String?)?
    var delegateShouldIndentWhileEditingRowAt: ((IndexPath) -> Bool)?
    var delegateTargetIndexPathForMoveFromRowAt: ((IndexPath,IndexPath) -> IndexPath)?
    var delegateDidEndDisplaying: ((UITableViewCell,IndexPath) -> Void)?
    var delegateDidEndDisplayingHeaderView: ((UIView,Int) -> Void)?
    var delegateDidEndDisplayingFooterView: ((UIView,Int) -> Void)?
    var delegateShouldShowMenuForRowAt: ((IndexPath) -> Bool)?
    var delegateCanPerformAction: ((Selector,IndexPath,Any?) -> Bool)?
    var delegatePerformAction: ((Selector,IndexPath,Any?) -> Void)?
    var delegateShouldHighlightRowAt: ((IndexPath) -> Bool)?
    var delegateDidHighlightRowAt: ((IndexPath) -> Void)?
    var delegateDidUnhighlightRowAt: ((IndexPath) -> Void)?
    var delegateCanFocusRowAt: ((IndexPath) -> Bool)?
    var delegateShouldUpdateFocusIn: ((UITableViewFocusUpdateContext) -> Bool)?
    var delegateDidUpdateFocusIn: ((UITableViewFocusUpdateContext,UIFocusAnimationCoordinator) -> Void)?
    var delegateIndexPathForPreferredFocusedView: (() -> IndexPath?)?
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if delegateHeightRowAt != nil {
            return delegateHeightRowAt!(indexPath)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if delegateEstimatedHeightForRowAt != nil {
            return delegateEstimatedHeightForRowAt!(indexPath)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if delegateIndentationLevelForRowAt != nil {
            return delegateIndentationLevelForRowAt!(indexPath)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegateWillDisplay?(cell,indexPath)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if delegateEditActionsForRowAt != nil {
            return delegateEditActionsForRowAt!(indexPath)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        delegateAccessoryButtonTappedForRowWith?(indexPath)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if delegateWillSelectRowAt != nil {
            return delegateWillSelectRowAt!(indexPath)
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateDidSelectRowAt?(indexPath)
    }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if delegateWillDeselectRowAt != nil {
            return delegateWillDeselectRowAt!(indexPath)
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegateDidDeselectRowAt?(indexPath)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if delegateViewForHeaderInSection != nil {
            return delegateViewForHeaderInSection!(section)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if delegateViewForFooterInSection != nil {
            return delegateViewForFooterInSection!(section)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if delegateHeightForHeaderInSection != nil {
            return delegateHeightForHeaderInSection!(section)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if delegateEstimatedHeightForHeaderInSection != nil {
            return delegateEstimatedHeightForHeaderInSection!(section)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if delegateHeightForFooterInSection != nil {
            return delegateHeightForFooterInSection!(section)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if delegateEstimatedHeightForFooterInSection != nil {
            return delegateEstimatedHeightForFooterInSection!(section)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if delegateWillDisplayHeaderView != nil {
            return delegateWillDisplayHeaderView!(view,section)
        }
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if delegateWillDisplayFooterView != nil {
            return delegateWillDisplayFooterView!(view,section)
        }
    }
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if delegateWillBeginEditingRowAt != nil {
            return delegateWillBeginEditingRowAt!(indexPath)
        }
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if delegateDidEndEditingRowAt != nil {
            return delegateDidEndEditingRowAt!(indexPath)
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if delegateEditingStyleForRowAt != nil {
            return delegateEditingStyleForRowAt!(indexPath)
        }
        return .delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if delegateTitleForDeleteConfirmationButtonForRowAt != nil {
            return delegateTitleForDeleteConfirmationButtonForRowAt!(indexPath)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if delegateShouldIndentWhileEditingRowAt != nil {
            return delegateShouldIndentWhileEditingRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if delegateTargetIndexPathForMoveFromRowAt != nil {
            return delegateTargetIndexPathForMoveFromRowAt!(sourceIndexPath,proposedDestinationIndexPath)
        }
        return proposedDestinationIndexPath
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegateDidEndDisplaying?(cell,indexPath)
    }
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        delegateDidEndDisplayingHeaderView?(view,section)
    }
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegateDidEndDisplayingFooterView?(view,section)
    }
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if delegateShouldShowMenuForRowAt != nil {
            return delegateShouldShowMenuForRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if delegateCanPerformAction != nil {
            return delegateCanPerformAction!(action,indexPath,sender)
        }
        return false
    }
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        delegatePerformAction?(action,indexPath,sender)
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if delegateShouldHighlightRowAt != nil {
            return delegateShouldHighlightRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        delegateDidHighlightRowAt?(indexPath)
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        delegateDidUnhighlightRowAt?(indexPath)
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if delegateCanFocusRowAt != nil {
            return delegateCanFocusRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        if delegateShouldUpdateFocusIn != nil {
            return delegateShouldUpdateFocusIn!(context)
        }
        return true
    }
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        delegateDidUpdateFocusIn?(context,coordinator)
    }
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        if delegateIndexPathForPreferredFocusedView != nil {
            return delegateIndexPathForPreferredFocusedView!()
        }
        return IndexPath(row: 0, section: 0)
    }
    
    /** UITableViewDataSource */
    
    var dataSourceNumberOfRowsInSection: ((Int) -> Int)?
    var dataSourceCellForRowAt: ((IndexPath) -> UITableViewCell)?
    var dataSourceNumberOfSections: (() -> Int)?
    var dataSourceSectionIndexTitles: (() -> [String]?)?
    var dataSourceSectionForSectionIndexTitle: ((String,Int) -> Int)?
    var dataSourceTitleForHeaderInSection: ((Int) -> String?)?
    var dataSourceTitleForFooterInSection: ((Int) -> String?)?
    var dataSourceEditingStyle: ((UITableViewCellEditingStyle,IndexPath) -> Void)?
    var dataSourceCanEditRowAt: ((IndexPath) -> Bool)?
    var dataSourceCanMoveRowAt: ((IndexPath) -> Bool)?
    var dataSourceMoveRowAt: ((IndexPath,IndexPath) -> Void)?

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSourceNumberOfRowsInSection != nil {
            return dataSourceNumberOfRowsInSection!(section)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSourceCellForRowAt != nil {
            return dataSourceCellForRowAt!(indexPath)
        }
        return UITableViewCell()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if dataSourceNumberOfSections != nil {
            return dataSourceNumberOfSections!()
        }
        return 0
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if dataSourceSectionIndexTitles != nil {
            return dataSourceSectionIndexTitles!()
        }
        return nil
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if dataSourceSectionForSectionIndexTitle != nil {
            return dataSourceSectionForSectionIndexTitle!(title,index)
        }
        return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dataSourceTitleForHeaderInSection != nil {
            return dataSourceTitleForHeaderInSection!(section)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if dataSourceTitleForFooterInSection != nil {
            return dataSourceTitleForFooterInSection!(section)
        }
        return nil
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        dataSourceEditingStyle?(editingStyle,indexPath)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if dataSourceCanEditRowAt != nil {
            return dataSourceCanEditRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if dataSourceCanMoveRowAt != nil {
            return dataSourceCanMoveRowAt!(indexPath)
        }
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataSourceMoveRowAt?(sourceIndexPath,destinationIndexPath)
    }
    
    
    /** UIScrollViewDelegate */
    var delegateScrollDidScroll: (() -> Void)?
    var delegateScrollWillBeginDragging: (() -> Void)?
    var delegateScrollWillEndDragging: ((CGPoint,UnsafeMutablePointer<CGPoint>) -> Void)?
    var delegateScrollDidEndDragging: ((Bool) -> Void)?
    var delegateScrollShouldScrollToTop: (() -> Bool)?
    var delegateScrollDidScrollToTop: (() -> Void)?
    var delegateScrollWillBeginDecelerating: (() -> Void)?
    var delegateScrollDidEndDecelerating: (() -> Void)?
    var delegateScrollViewForZooming: (() -> UIView?)?
    var delegateScrollWillBeginZooming: ((UIView?) -> Void)?
    var delegateScrollDidEndZooming: ((UIView?,CGFloat) -> Void)?
    var delegateScrollDidZoom: (() -> Void)?
    var delegateScrollDidEndScrollingAnimation: (() -> Void)?
    var delegateScrollDidChangeAdjustedContentInset: (() -> Void)?
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegateScrollDidScroll?()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegateScrollWillBeginDragging?()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegateScrollWillEndDragging?(velocity,targetContentOffset)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegateScrollDidEndDragging?(decelerate)
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool{
        if delegateScrollShouldScrollToTop != nil {
            return delegateScrollShouldScrollToTop!()
        }
        return true
    }
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegateScrollDidScrollToTop?()
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegateScrollWillBeginDecelerating?()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegateScrollDidEndDecelerating?()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if delegateScrollViewForZooming != nil {
            return delegateScrollViewForZooming!()
        }
        return nil
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView,
                                    with view: UIView?) {
        delegateScrollWillBeginZooming?(view)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                 with view: UIView?,
                                 atScale scale: CGFloat) {
        delegateScrollDidEndZooming?(view,scale)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegateScrollDidZoom?()
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegateScrollDidEndScrollingAnimation?()
    }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        delegateScrollDidChangeAdjustedContentInset?()
    }
    
    
}
