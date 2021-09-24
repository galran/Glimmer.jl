/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
import { tail } from '../../../../base/common/arrays.js';
import { SmallImmutableSet } from './smallImmutableSet.js';
import { lengthAdd, lengthZero, lengthHash } from './length.js';
class BaseAstNode {
    constructor(length) {
        this._length = length;
    }
    get length() {
        return this._length;
    }
}
export class PairAstNode extends BaseAstNode {
    constructor(length, category, children, unopenedBrackets) {
        super(length);
        this.category = category;
        this.children = children;
        this.unopenedBrackets = unopenedBrackets;
    }
    static create(category, openingBracket, child, closingBracket) {
        const length = computeLength(openingBracket, child, closingBracket);
        const children = new Array(1);
        children[0] = openingBracket;
        if (child) {
            children.push(child);
        }
        if (closingBracket) {
            children.push(closingBracket);
        }
        return new PairAstNode(length, category, children, child ? child.unopenedBrackets : SmallImmutableSet.getEmpty());
    }
    get kind() {
        return 2 /* Pair */;
    }
    get listHeight() {
        return 0;
    }
    canBeReused(expectedClosingCategories, endLineDidChange) {
        if (this.closingBracket === null) {
            // Unclosed pair ast nodes only
            // end at the end of the document
            // or when a parent node is closed.
            // This could be improved:
            // Only return false if some next token is neither "undefined" nor a bracket that closes a parent.
            return false;
        }
        if (expectedClosingCategories.intersects(this.unopenedBrackets)) {
            return false;
        }
        return true;
    }
    get closingBracket() {
        if (this.children.length <= 1) {
            return null;
        }
        if (this.children[1].kind === 1 /* Bracket */) {
            return this.children[1] || null;
        }
        return this.children[2] || null;
    }
    clone() {
        return new PairAstNode(this.length, this.category, clone(this.children), this.unopenedBrackets);
    }
}
function computeLength(openingBracket, child, closingBracket) {
    let length = openingBracket.length;
    if (child) {
        length = lengthAdd(length, child.length);
    }
    if (closingBracket) {
        length = lengthAdd(length, closingBracket.length);
    }
    return length;
}
export class ListAstNode extends BaseAstNode {
    constructor(length, listHeight, _items, _unopenedBrackets) {
        super(length);
        this.listHeight = listHeight;
        this._items = _items;
        this._unopenedBrackets = _unopenedBrackets;
    }
    static create(items) {
        if (items.length === 0) {
            return new ListAstNode(lengthZero, 0, items, SmallImmutableSet.getEmpty());
        }
        else {
            let length = items[0].length;
            let unopenedBrackets = items[0].unopenedBrackets;
            for (let i = 1; i < items.length; i++) {
                length = lengthAdd(length, items[i].length);
                unopenedBrackets = unopenedBrackets.merge(items[i].unopenedBrackets);
            }
            return new ListAstNode(length, items[0].listHeight + 1, items, unopenedBrackets);
        }
    }
    get kind() {
        return 4 /* List */;
    }
    get children() {
        return this._items;
    }
    get unopenedBrackets() {
        return this._unopenedBrackets;
    }
    canBeReused(expectedClosingCategories, endLineDidChange) {
        if (this._items.length === 0) {
            // might not be very helpful
            return true;
        }
        if (expectedClosingCategories.intersects(this.unopenedBrackets)) {
            return false;
        }
        let lastChild = this;
        while (lastChild.children.length > 0 && lastChild.kind === 4 /* List */) {
            lastChild = tail(lastChild.children);
        }
        return lastChild.canBeReused(expectedClosingCategories, endLineDidChange);
    }
    clone() {
        return new ListAstNode(this.length, this.listHeight, clone(this._items), this.unopenedBrackets);
    }
    handleChildrenChanged() {
        const items = this._items;
        if (items.length === 0) {
            return;
        }
        let length = items[0].length;
        let unopenedBrackets = items[0].unopenedBrackets;
        for (let i = 1; i < items.length; i++) {
            length = lengthAdd(length, items[i].length);
            unopenedBrackets = unopenedBrackets.merge(items[i].unopenedBrackets);
        }
        this._length = length;
        this._unopenedBrackets = unopenedBrackets;
    }
    /**
     * Appends the given node to the end of this (2,3) tree.
     * Returns the new root.
    */
    append(nodeToAppend) {
        const newNode = this._append(nodeToAppend);
        if (newNode) {
            return ListAstNode.create([this, newNode]);
        }
        return this;
    }
    /**
     * @returns Additional node after tree
    */
    _append(nodeToAppend) {
        // assert nodeToInsert.listHeight <= tree.listHeight
        if (nodeToAppend.listHeight === this.listHeight) {
            return nodeToAppend;
        }
        const lastItem = this._items[this._items.length - 1];
        const newNodeAfter = (lastItem.kind === 4 /* List */) ? lastItem._append(nodeToAppend) : nodeToAppend;
        if (!newNodeAfter) {
            this.handleChildrenChanged();
            return undefined;
        }
        // Can we take the element?
        if (this._items.length >= 3) {
            // assert tree.items.length === 3
            // we need to split to maintain (2,3)-tree property.
            // Send the third element + the new element to the parent.
            const third = this._items.pop();
            this.handleChildrenChanged();
            return ListAstNode.create([third, newNodeAfter]);
        }
        else {
            this._items.push(newNodeAfter);
            this.handleChildrenChanged();
            return undefined;
        }
    }
    /**
     * Prepends the given node to the end of this (2,3) tree.
     * Returns the new root.
    */
    prepend(nodeToPrepend) {
        const newNode = this._prepend(nodeToPrepend);
        if (newNode) {
            return ListAstNode.create([newNode, this]);
        }
        return this;
    }
    /**
     * @returns Additional node before tree
    */
    _prepend(nodeToPrepend) {
        // assert nodeToInsert.listHeight <= tree.listHeight
        if (nodeToPrepend.listHeight === this.listHeight) {
            return nodeToPrepend;
        }
        if (this.kind !== 4 /* List */) {
            throw new Error('unexpected');
        }
        const first = this._items[0];
        const newNodeBefore = (first.kind === 4 /* List */) ? first._prepend(nodeToPrepend) : nodeToPrepend;
        if (!newNodeBefore) {
            this.handleChildrenChanged();
            return undefined;
        }
        if (this._items.length >= 3) {
            // assert this.items.length === 3
            // we need to split to maintain (2,3)-this property.
            const first = this._items.shift();
            this.handleChildrenChanged();
            return ListAstNode.create([newNodeBefore, first]);
        }
        else {
            this._items.unshift(newNodeBefore);
            this.handleChildrenChanged();
            return undefined;
        }
    }
}
function clone(arr) {
    const result = new Array(arr.length);
    for (let i = 0; i < arr.length; i++) {
        result[i] = arr[i].clone();
    }
    return result;
}
const emptyArray = [];
export class TextAstNode extends BaseAstNode {
    get kind() {
        return 0 /* Text */;
    }
    get listHeight() {
        return 0;
    }
    get children() {
        return emptyArray;
    }
    get unopenedBrackets() {
        return SmallImmutableSet.getEmpty();
    }
    canBeReused(expectedClosingCategories, endLineDidChange) {
        // Don't reuse text from a line that got changed.
        // Otherwise, long brackes might not be detected.
        return !endLineDidChange;
    }
    clone() {
        return this;
    }
}
export class BracketAstNode extends BaseAstNode {
    constructor(length) {
        super(length);
    }
    static create(length) {
        const lengthKey = lengthHash(length);
        const cached = BracketAstNode.cacheByLength.get(lengthKey);
        if (cached) {
            return cached;
        }
        const node = new BracketAstNode(length);
        BracketAstNode.cacheByLength.set(lengthKey, node);
        return node;
    }
    get kind() {
        return 1 /* Bracket */;
    }
    get listHeight() {
        return 0;
    }
    get children() {
        return emptyArray;
    }
    get unopenedBrackets() {
        return SmallImmutableSet.getEmpty();
    }
    canBeReused(expectedClosingCategories, endLineDidChange) {
        // These nodes could be reused,
        // but not in a general way.
        // Their parent may be reused.
        return false;
    }
    clone() {
        return this;
    }
}
BracketAstNode.cacheByLength = new Map();
export class InvalidBracketAstNode extends BaseAstNode {
    constructor(category, length, denseKeyProvider) {
        super(length);
        this.unopenedBrackets = SmallImmutableSet.getEmpty().add(category, denseKeyProvider);
    }
    get kind() {
        return 3 /* UnexpectedClosingBracket */;
    }
    get listHeight() {
        return 0;
    }
    get children() {
        return emptyArray;
    }
    canBeReused(expectedClosingCategories, endLineDidChange) {
        return !expectedClosingCategories.intersects(this.unopenedBrackets);
    }
    clone() {
        return this;
    }
}
