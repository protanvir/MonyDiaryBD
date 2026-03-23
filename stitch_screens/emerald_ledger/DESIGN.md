```markdown
# Design System Specification: Editorial Finance

## 1. Overview & Creative North Star
### The North Star: "The Financial Sanctuary"
This design system rejects the cluttered, spreadsheet-like nature of traditional banking. Our vision is **The Financial Sanctuary**—a high-end, editorial experience that treats a user's balance not as a set of data points, but as a narrative of growth. 

We break the "standard app" template by using **intentional asymmetry** and **tonal layering**. Large, sophisticated typography (Manrope) provides an authoritative, magazine-like feel, while the Inter typeface ensures clinical legibility for transactional data. We prioritize breathing room over information density, ensuring every BDT (৳) symbol feels significant and every financial decision feels calm.

---

## 2. Colors & Surface Philosophy
The palette is anchored by **Deep Emerald (`primary`)**, representing organic growth. We move beyond flat UI by utilizing a sophisticated Material 3 tonal scale.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined solely through:
1.  **Background Color Shifts:** A `surface-container-low` card sitting on a `surface` background.
2.  **Tonal Transitions:** Using subtle shifts in the gray scale to imply structure.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine paper.
*   **Base:** `surface` (#f8fafa)
*   **Secondary Layer:** `surface-container-low` (#f2f4f4) for grouped content.
*   **Tertiary/Interactive Layer:** `surface-container-highest` (#e1e3e3) for elements that require immediate focus.

### The "Glass & Gradient" Rule
To elevate CTAs and Hero sections, use linear gradients transitioning from `primary` (#005344) to `primary_container` (#006d5b). For floating overlays (e.g., bottom sheets), apply **Glassmorphism**: use `surface` at 80% opacity with a `20px` backdrop blur to allow the brand colors to bleed through softly.

---

## 3. Typography
We utilize a dual-font strategy to balance editorial character with functional clarity.

*   **Display & Headlines (Manrope):** Used for large balance amounts and section headers. The wider tracking and geometric builds of Manrope convey modern authority.
    *   *Example:* `display-md` (2.75rem) for the primary ৳ Total Balance.
*   **Title & Body (Inter):** The workhorse for transactional data and labels. Inter’s tall x-height ensures the BDT symbol is legible even at `body-sm`.
*   **Hierarchy Tip:** Always pair a `headline-sm` (Manrope) with `body-md` (Inter) to create a clear "Editorial vs. Data" distinction.

---

## 4. Elevation & Depth
We convey hierarchy through **Tonal Layering** rather than traditional structural lines or heavy drop shadows.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section. This creates a soft, natural "lift" without visual noise.
*   **Ambient Shadows:** If a floating effect is required (e.g., a "Send Money" FAB), use a shadow with a 24px blur, 4% opacity, using the `on_surface` color as the shadow tint. Never use pure black (#000) for shadows.
*   **The "Ghost Border" Fallback:** If a container needs more definition (e.g., in high-glare outdoor usage), use the `outline_variant` (#bec9c4) at **15% opacity**. 100% opaque borders are strictly forbidden.

---

## 5. Components & Localized Elements

### The BDT (৳) Treatment
The currency symbol must never be smaller than the numerical value. In `display` scales, the ৳ symbol should be set at 80% opacity to let the numbers take the foreground while maintaining the localized identity.

### Buttons & CTAs
*   **Primary:** `primary` (#005344) with `on_primary` (#ffffff) text. Use `xl` (1.5rem) rounding.
*   **Secondary:** `secondary_container` (#d3e3df) with no border.
*   **Special MFS Buttons:** For bKash (Pink), Nagad (Orange), and Rocket (Purple), use the brand color as a **subtle tint** on a `surface-container` rather than a full-bleed saturated block, preserving the app's Emerald aesthetic.

### Cards & Lists
*   **No Dividers:** Forbid the use of line dividers. Use `spacing-4` (1.4rem) or `spacing-5` (1.7rem) to create separation through white space.
*   **Transaction Items:** Leading icons should use `primary_fixed` (#9df3dc) circles with Emerald icons to maintain the "Growth" theme.

### Input Fields
*   **Style:** Use `surface_container_highest` as the fill color.
*   **Active State:** Instead of a thick border, use a 2px bottom-heavy "glow" using the `primary` color.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical margins. For example, a `headline-lg` might have a wider left margin than the body text below it to create an editorial "grid break."
*   **Do** use `tertiary` (#940039) for negative cash flow (Expenses) and `primary` (#005344) for positive (Income).
*   **Do** embrace negative space. If a screen feels "empty," it is likely working.

### Don’t:
*   **Don’t** use standard 1px #EEEEEE dividers. If you feel the need for a line, increase the `spacing` token instead.
*   **Don’t** use sharp corners. Every interactive element must use at least `lg` (1rem) or `xl` (1.5rem) rounding to maintain the "Soft Minimalism" feel.
*   **Don’t** use high-contrast dark mode. Dark mode should use `surface_dim` as the base to reduce eye strain and maintain the "Sanctuary" vibe.