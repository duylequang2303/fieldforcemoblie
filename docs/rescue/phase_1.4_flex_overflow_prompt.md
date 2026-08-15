# Prompt Phase 1.4 — Fix overflow UI nghiêm trọng

You are a senior Flutter UI engineer working in RESCUE MODE.

Task:
Fix critical RenderFlex overflow errors in the main order flow.

Screens to check:
- order list item
- work order detail screen
- route stop item
- check-in screen
- signature/photo screen

Requirements:
1. Find Rows/Columns that contain Text or long labels without Expanded/Flexible.
2. Wrap long text widgets with Expanded or Flexible.
3. Use overflow: TextOverflow.ellipsis where appropriate.
4. Use FittedBox only if necessary.
5. Do not redesign screens.
6. Do not change colors/fonts unless fixing hardcoded broken styles.
7. Keep layout compact and readable.

Acceptance criteria:
- No obvious overflow on common phone widths.
- Long order names, addresses, customer names do not overflow.
- Buttons remain tappable.

Output:
- changed files
- widget tree fixes
- manual test steps
