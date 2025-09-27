from playwright.sync_api import sync_playwright, expect

def run_verification():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()

        # Navigate to the production server URL on port 3000
        page.goto("http://localhost:3000")

        # Wait for the main heading to be visible
        heading = page.get_by_role("heading", name="CloudCurio.cc")
        expect(heading).to_be_visible()

        # Take a screenshot for visual confirmation
        page.screenshot(path="jules-scratch/verification/verification.png")

        browser.close()

if __name__ == "__main__":
    run_verification()