/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { createCancelablePromise, RunOnceScheduler } from '../../../base/common/async.js';
import { onUnexpectedError } from '../../../base/common/errors.js';
import { MutableDisposable, toDisposable } from '../../../base/common/lifecycle.js';
import { Range } from '../../common/core/range.js';
import { InlineCompletionTriggerKind } from '../../common/modes.js';
import { BaseGhostTextWidgetModel, GhostText } from './ghostText.js';
import { provideInlineCompletions, UpdateOperation } from './inlineCompletionsModel.js';
import { inlineCompletionToGhostText } from './inlineCompletionToGhostText.js';
import { SuggestWidgetInlineCompletionProvider } from './suggestWidgetInlineCompletionProvider.js';
export class SuggestWidgetPreviewModel extends BaseGhostTextWidgetModel {
    constructor(editor, cache) {
        super(editor);
        this.cache = cache;
        this.suggestionInlineCompletionSource = this._register(new SuggestWidgetInlineCompletionProvider(this.editor));
        this.updateOperation = this._register(new MutableDisposable());
        this.updateCacheSoon = this._register(new RunOnceScheduler(() => this.updateCache(), 50));
        this.minReservedLineCount = 0;
        this._register(this.suggestionInlineCompletionSource.onDidChange(() => {
            this.updateCacheSoon.schedule();
            const suggestWidgetState = this.suggestionInlineCompletionSource.state;
            if (!suggestWidgetState) {
                this.minReservedLineCount = 0;
            }
            const newGhostText = this.ghostText;
            if (newGhostText) {
                this.minReservedLineCount = Math.max(this.minReservedLineCount, sum(newGhostText.parts.map(p => p.lines.length - 1)));
            }
            if (this.minReservedLineCount >= 1 && this.isSuggestionPreviewEnabled()) {
                this.suggestionInlineCompletionSource.forceRenderingAbove();
            }
            else {
                this.suggestionInlineCompletionSource.stopForceRenderingAbove();
            }
            this.onDidChangeEmitter.fire();
        }));
        this._register(this.cache.onDidChange(() => {
            this.onDidChangeEmitter.fire();
        }));
        this._register(this.editor.onDidChangeCursorPosition((e) => {
            if (this.isSuggestionPreviewEnabled()) {
                this.minReservedLineCount = 0;
                this.updateCacheSoon.schedule();
                this.onDidChangeEmitter.fire();
            }
        }));
        this._register(toDisposable(() => this.suggestionInlineCompletionSource.stopForceRenderingAbove()));
    }
    get isActive() {
        return this.suggestionInlineCompletionSource.state !== undefined;
    }
    isSuggestionPreviewEnabled() {
        const suggestOptions = this.editor.getOption(106 /* suggest */);
        return suggestOptions.preview;
    }
    updateCache() {
        return __awaiter(this, void 0, void 0, function* () {
            const state = this.suggestionInlineCompletionSource.state;
            if (!state || !state.selectedItemAsInlineCompletion) {
                return;
            }
            const info = {
                text: state.selectedItemAsInlineCompletion.text,
                range: state.selectedItemAsInlineCompletion.range,
            };
            const position = this.editor.getPosition();
            const promise = createCancelablePromise((token) => __awaiter(this, void 0, void 0, function* () {
                let result;
                try {
                    result = yield provideInlineCompletions(position, this.editor.getModel(), { triggerKind: InlineCompletionTriggerKind.Automatic, selectedSuggestionInfo: info }, token);
                }
                catch (e) {
                    onUnexpectedError(e);
                    return;
                }
                if (token.isCancellationRequested) {
                    return;
                }
                this.cache.setValue(this.editor, result, InlineCompletionTriggerKind.Automatic);
                this.onDidChangeEmitter.fire();
            }));
            const operation = new UpdateOperation(promise, InlineCompletionTriggerKind.Automatic);
            this.updateOperation.value = operation;
            yield promise;
            if (this.updateOperation.value === operation) {
                this.updateOperation.clear();
            }
        });
    }
    get ghostText() {
        var _a, _b;
        const suggestWidgetState = this.suggestionInlineCompletionSource.state;
        const originalInlineCompletion = minimizeInlineCompletion(this.editor.getModel(), suggestWidgetState === null || suggestWidgetState === void 0 ? void 0 : suggestWidgetState.selectedItemAsInlineCompletion);
        const augmentedCompletion = minimizeInlineCompletion(this.editor.getModel(), (_b = (_a = this.cache.value) === null || _a === void 0 ? void 0 : _a.completions[0]) === null || _b === void 0 ? void 0 : _b.toLiveInlineCompletion());
        const finalCompletion = augmentedCompletion
            && originalInlineCompletion
            && augmentedCompletion.text.startsWith(originalInlineCompletion.text)
            && augmentedCompletion.range.equalsRange(originalInlineCompletion.range)
            ? augmentedCompletion : (originalInlineCompletion || augmentedCompletion);
        const inlineCompletionPreviewLength = originalInlineCompletion ? ((finalCompletion === null || finalCompletion === void 0 ? void 0 : finalCompletion.text.length) || 0) - (originalInlineCompletion.text.length) : 0;
        const toGhostText = (completion) => {
            const mode = this.editor.getOptions().get(106 /* suggest */).previewMode;
            return completion
                ? (inlineCompletionToGhostText(completion, this.editor.getModel(), mode, this.editor.getPosition(), inlineCompletionPreviewLength) ||
                    // Show an invisible ghost text to reserve space
                    new GhostText(completion.range.endLineNumber, [], this.minReservedLineCount))
                : undefined;
        };
        const newGhostText = toGhostText(finalCompletion);
        return this.isSuggestionPreviewEnabled()
            ? newGhostText
            : undefined;
    }
}
function sum(arr) {
    return arr.reduce((a, b) => a + b, 0);
}
function lengthOfLongestCommonPrefix(str1, str2) {
    let i = 0;
    while (i < str1.length && i < str2.length && str1[i] === str2[i]) {
        i++;
    }
    return i;
}
function lengthOfLongestCommonSuffix(str1, str2) {
    let i = 0;
    while (i < str1.length && i < str2.length && str1[str1.length - i - 1] === str2[str2.length - i - 1]) {
        i++;
    }
    return i;
}
export function minimizeInlineCompletion(model, inlineCompletion) {
    if (!inlineCompletion) {
        return inlineCompletion;
    }
    const valueToReplace = model.getValueInRange(inlineCompletion.range);
    const commonPrefixLength = lengthOfLongestCommonPrefix(valueToReplace, inlineCompletion.text);
    const startOffset = model.getOffsetAt(inlineCompletion.range.getStartPosition()) + commonPrefixLength;
    const start = model.getPositionAt(startOffset);
    const remainingValueToReplace = valueToReplace.substr(commonPrefixLength);
    const commonSuffixLength = lengthOfLongestCommonSuffix(remainingValueToReplace, inlineCompletion.text);
    const end = model.getPositionAt(Math.max(startOffset, model.getOffsetAt(inlineCompletion.range.getEndPosition()) - commonSuffixLength));
    return {
        range: Range.fromPositions(start, end),
        text: inlineCompletion.text.substr(commonPrefixLength, inlineCompletion.text.length - commonPrefixLength - commonSuffixLength),
    };
}
