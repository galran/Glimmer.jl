/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
import { InvalidBracketAstNode, ListAstNode, PairAstNode } from './ast.js';
import { BeforeEditPositionMapper } from './beforeEditPositionMapper.js';
import { SmallImmutableSet } from './smallImmutableSet.js';
import { lengthGetLineCount, lengthIsZero, lengthLessThanEqual } from './length.js';
import { concat23Trees } from './concat23Trees.js';
import { NodeReader } from './nodeReader.js';
export function parseDocument(tokenizer, edits, oldNode, denseKeyProvider) {
    const parser = new Parser(tokenizer, edits, oldNode, denseKeyProvider);
    return parser.parseDocument();
}
class Parser {
    constructor(tokenizer, edits, oldNode, denseKeyProvider) {
        this.tokenizer = tokenizer;
        this.denseKeyProvider = denseKeyProvider;
        this._itemsConstructed = 0;
        this._itemsFromCache = 0;
        this.oldNodeReader = oldNode ? new NodeReader(oldNode) : undefined;
        this.positionMapper = new BeforeEditPositionMapper(edits, tokenizer.length);
    }
    parseDocument() {
        this._itemsConstructed = 0;
        this._itemsFromCache = 0;
        let result = this.parseList(SmallImmutableSet.getEmpty());
        if (!result) {
            result = ListAstNode.create([]);
        }
        return result;
    }
    parseList(expectedClosingCategories) {
        const items = new Array();
        while (true) {
            const token = this.tokenizer.peek();
            if (!token ||
                (token.kind === 2 /* ClosingBracket */ &&
                    expectedClosingCategories.has(token.category, this.denseKeyProvider))) {
                break;
            }
            const child = this.parseChild(expectedClosingCategories);
            if (child.kind === 4 /* List */ && child.children.length === 0) {
                continue;
            }
            items.push(child);
        }
        const result = concat23Trees(items);
        return result;
    }
    parseChild(expectingClosingCategories) {
        if (this.oldNodeReader) {
            const maxCacheableLength = this.positionMapper.getDistanceToNextChange(this.tokenizer.offset);
            if (!lengthIsZero(maxCacheableLength)) {
                const cachedNode = this.oldNodeReader.readLongestNodeAt(this.positionMapper.getOffsetBeforeChange(this.tokenizer.offset), curNode => {
                    if (!lengthLessThanEqual(curNode.length, maxCacheableLength)) {
                        return false;
                    }
                    const endLineDidChange = lengthGetLineCount(curNode.length) === lengthGetLineCount(maxCacheableLength);
                    const canBeReused = curNode.canBeReused(expectingClosingCategories, endLineDidChange);
                    return canBeReused;
                });
                if (cachedNode) {
                    this._itemsFromCache++;
                    this.tokenizer.skip(cachedNode.length);
                    return cachedNode;
                }
            }
        }
        this._itemsConstructed++;
        const token = this.tokenizer.read();
        switch (token.kind) {
            case 2 /* ClosingBracket */:
                return new InvalidBracketAstNode(token.category, token.length, this.denseKeyProvider);
            case 0 /* Text */:
                return token.astNode;
            case 1 /* OpeningBracket */:
                const set = expectingClosingCategories.add(token.category, this.denseKeyProvider);
                const child = this.parseList(set);
                const nextToken = this.tokenizer.peek();
                if (nextToken &&
                    nextToken.kind === 2 /* ClosingBracket */ &&
                    nextToken.category === token.category) {
                    this.tokenizer.read();
                    return PairAstNode.create(token.category, token.astNode, child, nextToken.astNode);
                }
                else {
                    return PairAstNode.create(token.category, token.astNode, child, null);
                }
            default:
                throw new Error('unexpected');
        }
    }
}
