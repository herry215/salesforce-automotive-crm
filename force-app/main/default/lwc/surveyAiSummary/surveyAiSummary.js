import { LightningElement, api, track } from "lwc";
import getSurveySummary from "@salesforce/apex/AiSummaryController.getSurveySummary";

export default class SurveyAiSummary extends LightningElement {
  @api recordId;
  @track summary = "";
  @track summaryHtml = "";
  @track isLoading = false;

  connectedCallback() {
    this.generateSummary();
  }

  generateSummary() {
    this.isLoading = true;
    this.summary = "";
    this.summaryHtml = "";
    getSurveySummary({ surveyId: this.recordId })
      .then((result) => {
        this.summary = result;
        this.summaryHtml = result
          .replace(/\*\*(.*?)\*\*/g, "<b>$1</b>")
          .replace(/\n/g, "<br/>");
        this.isLoading = false;
      })
      .catch((error) => {
        this.summary = "AI 요약 생성 중 오류가 발생했습니다.";
        this.summaryHtml = "AI 요약 생성 중 오류가 발생했습니다.";
        this.isLoading = false;
        console.error(error);
      });
  }
}
