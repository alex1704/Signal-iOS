//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalRingRTC
import SignalServiceKit
import UIKit

class IncomingReactionsView: UIView {
    enum Constants {
        static let viewWidth: CGFloat = 217
        fileprivate static let maxReactionsToDisplay = ReactionsModel.Constants.maxReactionsToDisplay
        fileprivate static let reactionSpacing: CGFloat = 12
        fileprivate static let reactionViewHeight: CGFloat = ReactionView.Constants.nameViewDimension
        fileprivate static let alphaFifth = 0.7
        fileprivate static let alphaFourth = 0.9
        fileprivate static let displayTime: TimeInterval = 4
        fileprivate static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Model

    private var reactionsModel = ReactionsModel()

    private func removeReactions(uuids: [UUID]) {
        self.reactionsModel.remove(uuids: uuids)
        self.applyLatestSnapshot()
    }

    func addReactions(reactions: [Reaction]) {
        self.reactionsModel.add(reactions: reactions)
        applyLatestSnapshot()
    }

    // MARK: - Updates

    private func applyLatestSnapshot(animated: Bool = true) {
        guard !isAnimationInProgress else {
            return
        }

        guard let changes = reactionsModel.changesSinceLastDiff() else {
            // Nil => No changes to apply.
            return
        }

        self.isAnimationInProgress = true

        var reactionViewsToAdd = [ReactionView]()
        for rxn in changes.reactionsToAdd {
            let view = ReactionView(reaction: rxn)
            reactionViewsToAdd.append(view)
            self.addSubview(view)
        }
        self.setReactionFrames(
            reactionViewsToLayout: reactionViewsToAdd,
            // Start the views one slot down so that they can animate up
            bottommostOriginY: self.bounds.maxY
        )

        let uuidsToRemove = changes.reactionsToRemove.map { $0.uuid }
        let reactionViewsToRemove = reactionViews.filter { reactionView in
            return uuidsToRemove.contains(where: { reactionView.reaction?.uuid == $0 })
        }

        let uuidsToMove = changes.reactionsToMove.map { $0.uuid }
        let reactionViewsToMove = reactionViews.filter { reactionView in
            return uuidsToMove.contains(where: { reactionView.reaction?.uuid == $0 })
        }

        let finalReactionViewsDisplayed = reactionViewsToMove + reactionViewsToAdd
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            // Adding reactions
            self.setReactionFrames(
                reactionViewsToLayout: reactionViewsToAdd,
                bottommostOriginY: self.bounds.maxY - Constants.reactionSpacing - Constants.reactionViewHeight
            )

            // Moving reactions
            let numSlotsToMove = CGFloat(changes.slotsToMove)
            if let last = reactionViewsToMove.last {
                self.setReactionFrames(
                    reactionViewsToLayout: reactionViewsToMove,
                    bottommostOriginY: last.frame.origin.y - numSlotsToMove*(Constants.reactionSpacing + Constants.reactionViewHeight)
                )
            }
            self.setReactionAlphas(finalViewsDisplayed: finalReactionViewsDisplayed)

            // Removing reactions
            for viewToRemove in reactionViewsToRemove {
                viewToRemove.alpha = 0
            }
        }, completion: { [weak self] _ in
            reactionViewsToRemove.forEach { $0.removeFromSuperview() }
            self?.reactionViews = finalReactionViewsDisplayed

            let addedUuids = changes.reactionsToAdd.map { $0.uuid }
            if !addedUuids.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.displayTime) { [weak self] in
                    self?.removeReactions(uuids: addedUuids)
                }
            }
            self?.isAnimationInProgress = false
        })
    }

    private var isAnimationInProgress = false {
        didSet {
            if oldValue && !isAnimationInProgress {
                applyLatestSnapshot()
            }
        }
    }

    // MARK: - View

    static var viewHeight: CGFloat {
        let sumReactionViewHeights = CGFloat(Constants.maxReactionsToDisplay) * Constants.reactionViewHeight
        let sumSpacingHeights = (CGFloat(Constants.maxReactionsToDisplay) - 1) * Constants.reactionSpacing
        return sumReactionViewHeights + sumSpacingHeights
    }

    private var reactionViews = [ReactionView]()

    /// Sets reaction frames.
    ///
    /// - Parameter reactionViewsToLayout: The `ReactionViews`, ordered from oldest
    ///                                    to newest, ie, top to bottom.
    /// - Parameter bottommostOriginY: The target origin y-value of the bottommost `ReactionView`.
    private func setReactionFrames(
        reactionViewsToLayout: [ReactionView],
        bottommostOriginY: CGFloat
    ) {
        var origin = CGPoint(x: 0, y: bottommostOriginY)
        for view in reactionViewsToLayout.reversed() {
            view.frame = CGRect(
                origin: origin,
                size: CGSize(
                    width: Constants.viewWidth,
                    height: Constants.reactionViewHeight
                )
            )
            origin = CGPoint(
                x: 0,
                y: origin.y - Constants.reactionSpacing - Constants.reactionViewHeight
            )
        }
    }

    private func setReactionAlphas(finalViewsDisplayed: [ReactionView]) {
        if finalViewsDisplayed.count == Constants.maxReactionsToDisplay {
            if let fifth = finalViewsDisplayed[safe: 0] {
                fifth.alpha = Constants.alphaFifth
            }
            if let fourth = finalViewsDisplayed[safe: 1] {
                fourth.alpha = Constants.alphaFourth
            }
        }
        if
            finalViewsDisplayed.count == Constants.maxReactionsToDisplay-1,
            let fourth = finalViewsDisplayed[safe: 0]
        {
            fourth.alpha = Constants.alphaFourth
        }
    }

    private class ReactionView: UIView {
        enum Constants {
            static let emojiDimension: CGFloat = 28
            static let nameViewDimension: CGFloat = 36
            static let nameLabelDimension: CGFloat = 20
            static let spacingBetweenEmojiAndName: CGFloat = 18
            static let nameCornerRadius: CGFloat = 18
            static let nameViewHInset: CGFloat = 16
            static let nameViewVInset: CGFloat = 8
        }

        private lazy var emojiLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = label.font.withSize(Constants.emojiDimension)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.heightAnchor.constraint(equalToConstant: Constants.emojiDimension)
            ])
            return label
        }()

        private lazy var nameLabel: UILabel = {
            let label = UILabel()
            label.textColor = .ows_white
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.heightAnchor.constraint(equalToConstant: Constants.nameLabelDimension)
            ])
            return label
        }()

        private lazy var nameView: UIView = {
            let view = UIView()
            view.backgroundColor = .ows_blackAlpha80
            view.layer.cornerRadius =  Constants.nameCornerRadius
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -Constants.nameViewHInset),
                view.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Constants.nameViewHInset),
                view.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.nameViewVInset),
                view.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -Constants.nameViewVInset),
                view.heightAnchor.constraint(equalToConstant: Constants.nameViewDimension)
            ])
            return view
        }()

        fileprivate var reaction: Reaction?

        convenience init(reaction: Reaction) {
            self.init(frame: .zero)
            self.reaction = reaction
            self.emojiLabel.text = reaction.emoji
            self.nameLabel.text = reaction.name
        }

        override init(frame: CGRect) {
            super.init(frame: frame)

            self.addSubview(self.emojiLabel)
            self.addSubview(self.nameView)
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: self.emojiLabel.leadingAnchor),
                self.emojiLabel.trailingAnchor.constraint(equalTo: self.nameView.leadingAnchor, constant: -Constants.spacingBetweenEmojiAndName),
                self.emojiLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.nameView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                self.nameView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // MARK: - Required

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Model classes/structs

class ReactionsModel {
    fileprivate enum Constants {
        static let maxReactionsToDisplay = 5
    }

    private var reactions = [Reaction]()
    private var prevSnapshot = [Reaction]()

    func add(reactions: [Reaction]) {
        AssertIsOnMainThread()
        self.reactions.append(contentsOf: reactions)
    }

    func remove(uuids: [UUID]) {
        AssertIsOnMainThread()
        self.reactions = self.reactions.filter { originalReaction in
            !uuids.contains(where: { $0 == originalReaction.uuid })
        }
    }

    func snapshot() -> [Reaction]? {
        AssertIsOnMainThread()
        return self.reactions
    }

    struct ReactionChangeSet {
        let reactionsToAdd: [Reaction]
        let reactionsToMove: [Reaction]
        let slotsToMove: Int
        let reactionsToRemove: [Reaction]
    }

    func changesSinceLastDiff() -> ReactionChangeSet? {
        AssertIsOnMainThread()
        guard let snapshot = snapshot() else { return nil }
        var trimmedSnapshot = snapshot
        // Trim the snapshot since we can never show more than `Constants.maxReactionsToDisplay` anyway.
        let excess = trimmedSnapshot.count - Constants.maxReactionsToDisplay
        if excess > 0  {
            trimmedSnapshot = Array(trimmedSnapshot.dropFirst(excess))
        }
        let currSnapshot = trimmedSnapshot

        var reactionsToAdd = [Reaction]()
        for newRxn in currSnapshot {
            if !self.prevSnapshot.contains(where: { $0.uuid == newRxn.uuid }) {
                reactionsToAdd.append(newRxn)
            }
        }

        var reactionsToMove = [Reaction]()
        for rxn in currSnapshot {
            if self.prevSnapshot.contains(where: { $0.uuid == rxn.uuid }) {
                reactionsToMove.append(rxn)
            }
        }

        var reactionsToRemove = [Reaction]()
        for oldRxn in self.prevSnapshot {
            if !currSnapshot.contains(where: { $0.uuid == oldRxn.uuid }) {
                reactionsToRemove.append(oldRxn)
            }
        }

        self.prevSnapshot = currSnapshot
        self.reactions = currSnapshot

        var slotsToMove = 0
        if !reactionsToMove.isEmpty {
            slotsToMove = reactionsToAdd.count
        }

        if reactionsToAdd.isEmpty && (reactionsToMove.isEmpty || slotsToMove == 0) && reactionsToRemove.isEmpty {
            // No changes
            return nil
        }

        return ReactionChangeSet(
            reactionsToAdd: reactionsToAdd,
            reactionsToMove: reactionsToMove,
            slotsToMove: slotsToMove,
            reactionsToRemove: reactionsToRemove
        )
    }
}

struct Reaction {
    let emoji: String
    let name: String
    let timestamp: TimeInterval

    let uuid = UUID()

    init(
        emoji: String,
        name: String,
        timestamp: TimeInterval
    ) {
        self.emoji = emoji
        self.name = name
        self.timestamp = timestamp
    }
}
