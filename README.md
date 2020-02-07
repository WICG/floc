# Federated Learning of Cohorts (FLoC)
This is an explainer for a new way that browsers could enable interest-based advertising on the web, in which the companies who today observe the browsing behavior of individuals instead observe the behavior of a cohort (or "flock") of similar people.

## Overview

The choice of what ads to show on a web page may typically be based on three broad categories of information: (1) First-party and contextual information (e.g., "put this ad on web pages about motorcycles"); (2) general information about the interests of the person who is going to see the ad (e.g., “show this ad to Classical Music Lovers”); and (3) specific previous actions the person has taken (e.g., "offer a discount on some shoes that you left in a shopping cart"). **This document addresses category (2), ads targeting based on someone's general interests.**  For personalized advertising in category (3), please check out the [TURTLEDOVE](https://github.com/michaelkleber/turtledove) proposal.

  

In today's web, people’s interests are typically inferred based on observing what sites or pages they visit, which relies on tracking techniques like third-party cookies or less-transparent mechanisms like device fingerprinting. It would be better for privacy if interest-based advertising could be accomplished without needing to collect a particular individual’s browsing history.

  

We plan to explore ways in which a browser can group together people with similar browsing habits, so that ad tech companies can observe the habits of large groups instead of the activity of individuals. Ad targeting could then be partly based on what group the person falls into.

  

Browsers would need a way to form clusters that are both useful and private: Useful by collecting people with similar enough interests and producing labels suitable for machine learning, and private by forming large clusters that don't reveal information that's too personal, when the clusters are created, or when they are used.

  

A FLoC Key, or "flock", is a short name that is shared by a large number (thousands) of people, derived by the browser from its user’s browsing history. The browser updates the flock over time as its user traverses the web. The value is made available to websites via a Client Hint:

```http
Accept-CH = Sec-CH-Flock
```
```http
GET https://ad-network.example/serve_ad.html?width=300&height=250
Referer: https://allaboutmotorcycles.com/home.html
Sec-CH-Flock: 43A7
```

The browser uses machine learning algorithms to develop a flock based on the sites that an individual visits. The algorithms might be based on the URLs of the visited sites, on the content of those pages, or other factors. The central idea is that these input features to the algorithm, including the web history, are kept local on the browser and are not uploaded elsewhere — the browser only exposes the generated flock. The browser ensures that flocks are well distributed, so that each flock represents thousands of people. The browser may further leverage other anonymization methods, such as differential privacy. The number of flocks should be small, to reinforce that they cannot carry detailed information — short flock names ("43A7") can help make that clear.

## Privacy and Security Considerations
There are several abuse scenarios this proposal must consider.

### Revealing People’s Interests to the Web
This API democratizes access to some information about an individual’s general browsing history (and thus, general interests) to any site that opts into the header. This is in contrast to today’s world, in which cookies or other tracking techniques may be used to collate someone’s browsing activity across many sites.

Sites that know a person’s PII (e.g., when people sign in using their email address) could record and reveal their flock. This means that information about an individual's interests may eventually become public. This is not ideal, but still better than today’s situation in which PII can be joined to exact browsing history obtained via third-party cookies.

As such, there will be people for whom providing this information in exchange for funding the web ecosystem is an unacceptable trade-off. Whether the browser sends a real FLoC or a random one is user controllable.

### Tracking people via their flock
A flock could be used as a user identifier. It may not have enough bits of information to individually identify someone, but in combination with other information (such as an IP address), it might. One design mitigation is to ensure flock sizes are large enough that they are not useful for tracking. The [Privacy Budget explainer](https://github.com/bslassey/privacy-budget) points towards another relevant tool that FLoC could be constrained by.

### Sensitive Categories
A flock might reveal sensitive information. As a first mitigation, the browser should remove sensitive categories from its data collection. But this does not mean sensitive information can’t be leaked. Some people are sensitive to categories that others are not, and there is no globally accepted notion of sensitive categories.

Flocks could be evaluated for fairness by measuring and limiting their deviation from population-level demographics with respect to the prevalence of sensitive categories, to prevent their use as proxies for a sensitive category. However, this evaluation would require knowing how many individual people in each flock were in the sensitive categories, information which could be difficult or intrusive to obtain.

It should be clear that FLoC will never be able to prevent all misuse. There will be categories that are sensitive in contexts that weren't predicted. Beyond FLoC's technical means of preventing abuse, sites that use flock will need to ensure that people are treated fairly, just as they must with algorithmic decisions made based on any other data today.
