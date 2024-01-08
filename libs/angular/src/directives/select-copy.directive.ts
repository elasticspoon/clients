import { Directive, ElementRef, HostListener } from "@angular/core";

import { ClientType } from "@bitwarden/common/enums";
import { PlatformUtilsService } from "@bitwarden/common/platform/abstractions/platform-utils.service";

@Directive({
  selector: "[appSelectCopy]",
})
// this directive is meant to copy fields where each character is a span
// such as the password generator and the password field when unhidden
export class SelectCopyDirective {
  constructor(
    private el: ElementRef,
    private platformUtilsService: PlatformUtilsService,
  ) {}

  @HostListener("copy") onCopy() {
    if (window == null) {
      return;
    }

    let selectCopy = "";
    const selection = window.getSelection();
    // there are two situations there are mutliple ranges
    // 1. in firefox when selecting with ctrl + mouse
    // 2. when selecting within a table
    //
    // 2 does not apply since this directive is only used to select from password generator
    // or from password when unhidden
    for (let i = 0; i < selection.rangeCount; i++) {
      const range = selection.getRangeAt(i);
      const contents = range.cloneContents();

      const textNodeContents = [].map.call(
        contents.childNodes,
        (node: Element) => node.textContent,
      );

      selectCopy += textNodeContents.join("");
    }

    const timeout = this.platformUtilsService.getClientType() === ClientType.Desktop ? 100 : 0;
    setTimeout(() => {
      this.platformUtilsService.copyToClipboard(selectCopy, { window: window });
    }, timeout);
  }
}
