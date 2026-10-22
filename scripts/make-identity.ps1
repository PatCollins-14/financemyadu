# Generates src/data/identity.json from source/extract.json. Every page reads identity.json.
. "$PSScriptRoot\lib.ps1"
$root = Get-Root
$x = Read-Json (Join-Path $root 'source\extract.json')
$id = [ordered]@{
  _generated = "from source/extract.json (retrieved $($x._meta.retrieved)); do not edit by hand"
  person = [ordered]@{
    fullName = $x.identity.person_name
    shortName = 'Pat Collins'
    jobTitle = $x.identity.title_on_site
    nmls = $x.identity.nmls_individual
    dre = '#02143449'
    dreNote = "Confirmed by Pat in chat on 2026-10-23. The live website footer still labels it 'BRE'; compliance to confirm the label."
    yearsExperience = '30+ years'
    yearsExperienceNote = "Pat's own statement in the build brief; the website says 'decades in business, sales, real estate'"
    aboutText = $x.identity.about_pat
    audiences = $x.identity.audiences
    principles = $x.identity.principles
  }
  company = [ordered]@{
    name = $x.identity.company
    nmls = $x.identity.company_nmls
    address = $x.identity.address
    brand = $x.identity.brand
    poweredBy = $x.identity.powered_by
  }
  contact = [ordered]@{
    phone = $x.contact.phone
    phoneTel = 'tel:+1' + ($x.contact.phone -replace '\D', '')
    email = $x.contact.email
    bookingUrl = $x.contact.booking_url
    applicationUrl = $x.contact.application_url
    applicationUrlNote = '[PAT: confirm application link for this campaign]'
    nmlsConsumerAccess = $x.contact.nmls_consumer_access
  }
  social = [ordered]@{
    facebook = $x.contact.social.facebook
    sameAs = @($x.contact.social.facebook)
    otherProfiles = '[PAT: other real profile URLs for sameAs (YouTube, newsletter, LinkedIn, Google Business Profile)]'
  }
  reviews = [ordered]@{
    label = 'E Mortgage Capital customer reviews from BBB'
    note = 'These reviews are about E Mortgage Capital and are not specific to ADU financing.'
    bbbProfile = $x.contact.review_profiles.bbb
    updatedOnSite = $x.reviews_displayed_home.updated_on_site
    items = $x.reviews_displayed_home.items
  }
  assets = [ordered]@{
    logo = 'assets/lthm-logo-orange.png'
    equalHousing = 'assets/equal-housing-opportunity.png'
    aime = 'assets/aime-brokers-are-better.webp'
    aimeApproved = $false
  }
  siteLinks = [ordered]@{
    home = 'https://letstalkhomemortgage.com/'
    heloc = 'https://letstalkhomemortgage.com/heloc-loans/'
    refinance = 'https://letstalkhomemortgage.com/refinance/'
    reverse = 'https://letstalkhomemortgage.com/reverse-mortgage/'
    nonqm = 'https://letstalkhomemortgage.com/non-qm-mortgage/'
    contact = 'https://letstalkhomemortgage.com/contact-us/'
    articles = 'https://letstalkhomemortgage.com/articles/'
    equityArticle = 'https://letstalkhomemortgage.com/home-equity-next-move-2026/'
    multigenArticle = 'https://letstalkhomemortgage.com/multigenerational-home-value-2026/'
    agingParentArticle = 'https://letstalkhomemortgage.com/lets-talk-the-cost-of-caring-for-an-aging-parent/'
    privacy = 'https://letstalkhomemortgage.com/privacy-policy/'
    terms = 'https://letstalkhomemortgage.com/terms-and-conditions/'
    accessibility = 'https://letstalkhomemortgage.com/accessibility/'
  }
  disclosure = [ordered]@{
    standard = $x.disclosure_footer_text
    adu = 'Rental income is not guaranteed and may not be counted for qualification under every program.'
    smsConsent = $x.sms_consent_text_on_site + ' [PAT: compliance to approve final consent wording]'
  }
  sourceNote = "SOURCE: https://letstalkhomemortgage.com/ | retrieved $($x._meta.retrieved)"
}
Write-Text (Join-Path $root 'src\data\identity.json') (($id | ConvertTo-Json -Depth 8))
Write-Host "identity.json written"
