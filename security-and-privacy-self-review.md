## FLoC Security and Privacy Self-Review

Responses to the [Self-Review Questionnaire: Security and Privacy](https://www.w3.org/TR/security-privacy-questionnaire/) for the [FLoC API](https://github.com/WICG/floc).

#### 1. What information might this feature expose to Web sites or other parties, and for what purposes is that exposure necessary?
An interest cohort (integer shared by thousands of users) that represents the user's general browsing interests will be exposed to the web through a javascript API. The browser uses machine learning algorithms to develop this interest cohort based on the sites that an individual visits. See question [12. What temporary identifiers might this specification create or expose to the web?] for more details.

In today's web, people's interests are typically inferred based on observing what sites or pages they visit, which relies on tracking techniques like third-party cookies or less-transparent mechanisms like device fingerprinting. User privacy could be better protected if interest-based advertising could be accomplished without needing to collect a particular individual's exact browsing history.

#### 2. Do features in your specification expose the minimum amount of information necessary to enable their intended uses?
Yes. We expose just enough information to be useful, while ensuring that each cohort represents thousands of users.

#### 3. How do the features in your specification deal with personal information, personally-identifiable information (PII), or information derived from them?
The raw data into the ML algorithm may contain PII but the final exposed interest chort should be in no way correlated with the PII.

#### 4. How does this specification deal with sensitive information?
The specification will advise that implementers verify that the interest cohorts that they produce are not correlated with sensitive information.

#### 5. Does this specification introduce new state for an origin that persists across browsing sessions?
No.

#### 6. What information from the underlying platform, e.g. configuration data, is exposed by this specification to an origin?
No information about the underlying platform is exposed.

#### 7. Does this specification allow an origin access to sensors on a user’s device
No.

#### 8. What data does this specification expose to an origin? Please also document what data is identical to data exposed by other features, in the same or different contexts.
The interest cohort is exposed. See question [12. What temporary identifiers might this specification create or expose to the web?] for more details.

The data is not identical to the data exposed by any other existing features.

#### 9. Does this specification enable new script execution/loading mechanisms?
No.

#### 10. Does this specification allow an origin to access other devices?
No.

#### 11. Does this specification allow an origin some measure of control over a user agent’s native UI?
No.

#### 12. What temporary identifiers might this specification create or expose to the web?
The interest cohort is a temporary identifier. The browser could use machine learning algorithms to develop a cohort based on the sites that the user visits. The algorithms might be based on the URLs of the visited sites, on the content of those pages, or other factors. The input features to the algorithm should be kept local on the browser and should not be uploaded elsewhere — the browser only exposes the generated cohort.

The specification will advise the implementers to ensure that the identifier is anonymous and doesn't carry sensitive information. The following is a more concrete example of what Chrome is doing at the experimentation phase.

##### Interest Cohort Computation
The interest cohort will be calculated by 1) sim-hashing the navigation history over the last 7 days, and then 2) post-processing the sim-hash to merge small and adjacent cohorts into larger ones, such that each cohort contains at least thousands of people. The interest cohort can also be blocked if server side analysis determined it to be sensitive.

The interest cohort will be calculated/refreshed every 7 days. If the browser is not alive at the scheduled refresh time, the next update will occur when the browser starts up the next time.

The interest cohort is eligible to be calculated if the followings hold at the calculation time:
- 3rd-party cookies are not blocked
- History has at least 3 interest-cohort-computation-eligible entries over the past 7 days, where interest-cohort-computation-eligible means the page had some ad resource or the API was used, AND it was not restricted by the interest-cohort permission policy.

If the interest cohort is not eligible to be calculated or is blocked, an invalid/null value will be given.

##### Deletion / Invalidation
During each 7-days period, the interest cohort can be invalidated if cookies are deleted, or if recent histories are deleted.

##### Exposing the Interest Cohort
The interest cohort is exposed through the document.interestCohort API. The API is permitted to be used if the followings hold at API usage time:
- 3rd-party cookies are not blocked
- Cookies access is allowed in the document
- The interest-cohort permission policy allows it in the document

If the API is not permitted, or if the interest cohort is invalid/null, an exception will be thrown. Otherwise, the interest cohort will be returned.

#### 13. How does this specification distinguish between behavior in first-party and third-party contexts?
First-party and third-party contexts may have different access permissions. See the "Exposing the Interest Cohort" section under Question 12.

#### 14. How do the features in this specification work in the context of a browser's Private Browsing or Incognito mode?
The behavior is the same as if the interest cohort is invalid/null in a regular browsing mode, i.e. an exception will be thrown.

#### 15. Does this specification have both "Security Considerations" and "Privacy Considerations" sections?
There are no known security impacts of the features in this specification.

#### 16. Do features in your specification enable downgrading default security characteristics?
No.

#### 17. What should this questionnaire have asked?
N/A
