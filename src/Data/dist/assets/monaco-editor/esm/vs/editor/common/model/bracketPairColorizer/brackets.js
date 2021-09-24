/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
import { escapeRegExpCharacters } from '../../../../base/common/strings.js';
import { LanguageConfigurationRegistry } from '../../modes/languageConfigurationRegistry.js';
import { BracketAstNode } from './ast.js';
import { toLength } from './length.js';
import { Token } from './tokenizer.js';
export class BracketTokens {
    constructor() {
        this.hasRegExp = false;
        this._regExpGlobal = null;
        this.map = new Map();
    }
    static createFromLanguage(languageId, customBracketPairs) {
        const brackets = [...(LanguageConfigurationRegistry.getColorizedBracketPairs(languageId))];
        const tokens = new BracketTokens();
        let idxOffset = 0;
        for (const pair of brackets) {
            tokens.addBracket(languageId, pair[0], 1 /* OpeningBracket */, idxOffset);
            tokens.addBracket(languageId, pair[1], 2 /* ClosingBracket */, idxOffset);
            idxOffset++;
        }
        for (const pair of customBracketPairs) {
            idxOffset++;
            tokens.addBracket(languageId, pair[0], 1 /* OpeningBracket */, idxOffset);
            tokens.addBracket(languageId, pair[1], 2 /* ClosingBracket */, idxOffset);
        }
        return tokens;
    }
    addBracket(languageId, value, kind, idx) {
        const length = toLength(0, value.length);
        this.map.set(value, new Token(length, kind, 
        // A language can have at most 1000 bracket pairs.
        languageId * 1000 + idx, languageId, BracketAstNode.create(length)));
    }
    getRegExpStr() {
        if (this.isEmpty) {
            return null;
        }
        else {
            const keys = [...this.map.keys()];
            keys.sort();
            keys.reverse();
            return keys.map(k => escapeRegExpCharacters(k)).join('|');
        }
    }
    /**
     * Returns null if there is no such regexp (because there are no brackets).
    */
    get regExpGlobal() {
        if (!this.hasRegExp) {
            const regExpStr = this.getRegExpStr();
            this._regExpGlobal = regExpStr ? new RegExp(regExpStr, 'g') : null;
            this.hasRegExp = true;
        }
        return this._regExpGlobal;
    }
    getToken(value) {
        return this.map.get(value);
    }
    get isEmpty() {
        return this.map.size === 0;
    }
}
export class LanguageAgnosticBracketTokens {
    constructor(customBracketPairs) {
        this.customBracketPairs = customBracketPairs;
        this.languageIdToBracketTokens = new Map();
    }
    didLanguageChange(languageId) {
        const existing = this.languageIdToBracketTokens.get(languageId);
        if (!existing) {
            return false;
        }
        const newRegExpStr = BracketTokens.createFromLanguage(languageId, this.customBracketPairs).getRegExpStr();
        return existing.getRegExpStr() !== newRegExpStr;
    }
    getSingleLanguageBracketTokens(languageId) {
        let singleLanguageBracketTokens = this.languageIdToBracketTokens.get(languageId);
        if (!singleLanguageBracketTokens) {
            singleLanguageBracketTokens = BracketTokens.createFromLanguage(languageId, this.customBracketPairs);
            this.languageIdToBracketTokens.set(languageId, singleLanguageBracketTokens);
        }
        return singleLanguageBracketTokens;
    }
}
