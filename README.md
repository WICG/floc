# Federated Learning of Cohorts (FLoC)
This is an explainer for a new way that browsers could enable interest-based advertising on the web, in which the companies who today observe the browsing behavior of individuals instead observe the behavior of a cohort of similar people.

## Overview

The choice of what ads to show on a web page may typically be based on three broad categories of information: (1) First-party and contextual information (e.g., "put this ad on web pages about motorcycles"); (2) general information about the interests of the person who is going to see the ad (e.g., “show this ad to Classical Music Lovers”); and (3) specific previous actions the person has taken (e.g., "offer a discount on some shoes that you left in a shopping cart"). **This document addresses category (2), ads targeting based on someone's general interests.**  For personalized advertising in category (3), please check out the [TURTLEDOVE](https://github.com/michaelkleber/turtledove) proposal.

  

In today's web, people’s interests are typically inferred based on observing what sites or pages they visit, which relies on tracking techniques like third-party cookies or less-transparent mechanisms like device fingerprinting. It would be better for privacy if interest-based advertising could be accomplished without needing to collect a particular individual’s browsing history.

  

We plan to explore ways in which a browser can group together people with similar browsing habits, so that ad tech companies can observe the habits of large groups instead of the activity of individuals. Ad targeting could then be partly based on what group the person falls into.

  

Browsers would need a way to form clusters that are both useful and private: Useful by collecting people with similar enough interests and producing labels suitable for machine learning, and private by forming large clusters that don't reveal information that's too personal, when the clusters are created, or when they are used.

  

A FLoC cohort is a short name that is shared by a large number (thousands) of people, derived by the browser from its user’s browsing history. The browser updates the cohort over time as its user traverses the web. The value is made available to websites via a new JavaScript API:

```javascript
cohort = await document.interestCohort();
url = new URL("https://ads.example/getCreative");
url.searchParams.append("cohort", cohort);
creative = await fetch(url);
```

The browser uses machine learning algorithms to develop a cohort based on the sites that an individual visits. The algorithms might be based on the URLs of the visited sites, on the content of those pages, or other factors. The central idea is that these input features to the algorithm, including the web history, are kept local on the browser and are not uploaded elsewhere — the browser only exposes the generated cohort. The browser ensures that cohorts are well distributed, so that each represents thousands of people. The browser may further leverage other anonymization methods, such as differential privacy. The number of cohorts should be small, to reinforce that they cannot carry detailed information — short cohort names ("43A7") can help make that clear.

## Privacy and Security Considerations
There are several abuse scenarios this proposal must consider.

### Revealing People’s Interests to the Web
This API democratizes access to some information about an individual’s general browsing history (and thus, general interests) to any site that opts into it. This is in contrast to today’s world, in which cookies or other tracking techniques may be used to collate someone’s browsing activity across many sites.

Sites that know a person’s PII (e.g., when people sign in using their email address) could record and reveal their cohort. This means that information about an individual's interests may eventually become public. This is not ideal, but still better than today’s situation in which PII can be joined to exact browsing history obtained via third-party cookies.

As such, there will be people for whom providing this information in exchange for funding the web ecosystem is an unacceptable trade-off. Whether the browser sends a real FLoC or a random one is user controllable.

### Tracking people via their cohort
A cohort could be used as a user identifier. It may not have enough bits of information to individually identify someone, but in combination with other information (such as an IP address), it might. One design mitigation is to ensure cohort sizes are large enough that they are not useful for tracking. The [Privacy Budget explainer](https://github.com/bslassey/privacy-budget) points towards another relevant tool that FLoC could be constrained by.

### Sensitive Categories
A cohort might reveal sensitive information. As a first mitigation, the browser should remove sensitive categories from its data collection. But this does not mean sensitive information can’t be leaked. Some people are sensitive to categories that others are not, and there is no globally accepted notion of sensitive categories.

Cohorts could be evaluated for fairness by measuring and limiting their deviation from population-level demographics with respect to the prevalence of sensitive categories, to prevent their use as proxies for a sensitive category. However, this evaluation would require knowing how many individual people in each cohort were in the sensitive categories, information which could be difficult or intrusive to obtain.

It should be clear that FLoC will never be able to prevent all misuse. There will be categories that are sensitive in contexts that weren't predicted. Beyond FLoC's technical means of preventing abuse, sites that use cohorts will need to ensure that people are treated fairly, just as they must with algorithmic decisions made based on any other data today.

### Opting Out of Computation
A site should be able to declare that it does not want to be included in the user's list of sites for cohort calculation. This can be accomplished via a new `interest-cohort` [permissions policy](https://www.w3.org/TR/permissions-policy-1/). This policy will be default allow. Any frame that is not allowed `interest-cohort` permission will have a default value returned when they call `document.interestCohort()`. If the main frame does not have `interest-cohort` permission then the page visit will not be included in interest cohort calculation.

The simplest way for most sites to opt out of cohort calculation is to add a meta tag in the page head.

```html
<meta http-equiv="Permissions-Policy" content="interest-cohort=()">
```

## Proof of Concept Experiment
As a first step toward implementing FLoC, browsers will need to perform closed experiments in order to find a good clustering method to assign users to cohorts and to analyze them to ensure that they’re not revealing sensitive information about users. We consider this the proof-of-concept (POC) stage. The initial phase will be an experiment with cohorts to ensure that they are sufficiently private to be made publicly available to the web. This phase will inform any potential additional phases which would focus on other goals.

For this initial phase of Chrome’s Proof-Of-Concept, simple client-side methods will be used to calculate the user’s cohort based on all of the sites that they visit with public IP addresses. The qualifying subset of users who meet the criteria described below will have their cohort temporarily logged with their sync data to perform the sensitivity analysis by Chrome described below. The collection of cohorts will be analyzed to ensure that cohorts are of sufficient size and do not correlate too strongly with known [sensitive categories](https://support.google.com/adspolicy/answer/143465?hl=en). Cohorts that don’t pass the test will be concealed by the browser in any subsequent phases.

### How the Interest Cohort will be calculated
This is where most of the experimentation will occur as we explore the privacy and utility space of FLoC. Our first approach involves applying a SimHash algorithm to the domains of the sites visited by the user in order to cluster users that visit similar sites together. Other ideas include adding other features, such as the full path of the URL or categories of pages provided by an on-device classifier. We may also apply federated learning methods to estimate client models in a distributed fashion. To further enhance user privacy, we will also experiment with adding noise to the output of the hash function, or with occasionally replacing the user's true cohort with a random one.

### Qualifying users for whom a cohort will be logged with their sync data
For Chrome’s POC, cohorts will be logged with sync in a limited set of circumstances. Namely, all of the following conditions must be met:

1. The user is logged into a Google account and opted to sync history data with Chrome
1. The user does not block third-party cookies
1. The user’s [Google Activity Controls](https://myaccount.google.com/activitycontrols) have the following enabled:
    1. “Web & App Activity”
    1. “Include Chrome history and activity from sites, apps, and devices that use Google services”
1. The user’s [Google Ad Settings](https://adssettings.google.com/) have the following enabled:
    1. “Ad Personalization”
    1. “Also use your activity & information from Google services to personalize ads on websites and apps that partner with Google to show ads.” 

### Sites which interest cohorts will be calculated on
All sites with publicly routable IP addresses that the user visits when not in incognito mode will be included in the POC cohort calculation. 

### Excluding sensitive categories
We will analyze the resulting cohorts for correlations between cohort and sensitive categories, including the prohibited categories defined [here](https://support.google.com/adspolicy/answer/143465?hl=en). This analysis is designed to protect user privacy by evaluating only whether a cohort may be sensitive, in the abstract, without learning why it is sensitive, i.e., without computing or otherwise inferring specific sensitive categories that may be associated with that cohort. Cohorts that reveal sensitive categories will be blocked or the clustering algorithm will be reconfigured to reduce the correlation. 
