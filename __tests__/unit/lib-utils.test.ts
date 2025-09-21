import { formatCurrency, formatDate } from "@/lib/utils";

// Tests for lib/utils.ts
describe("Utils", () => {
  describe("formatCurrency", () => {
    it("should format currency correctly", () => {
      expect(formatCurrency(1000)).toBe("$1,000.00");
      expect(formatCurrency(1000.5)).toBe("$1,000.50");
      expect(formatCurrency(0)).toBe("$0.00");
    });
  });

  describe("formatDate", () => {
    it("should format date correctly", () => {
      // Create a date in local timezone to avoid timezone issues
      const date = new Date(2023, 0, 1); // January 1, 2023
      const result = formatDate(date);
      // Check that the result contains the expected parts
      expect(result).toContain("2023");
      expect(result).toContain("January");
      expect(result).toContain("1");
    });
  });
});