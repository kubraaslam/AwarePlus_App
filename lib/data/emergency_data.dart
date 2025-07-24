class EmergencyContact {
  final String title;
  final List<ContactDetail> contacts;

  EmergencyContact({required this.title, required this.contacts});
}

class ContactDetail {
  final String name;
  final List<String> phones;
  final String? website;
  final String? email;
  final String description;

  ContactDetail({
    required this.name,
    this.phones = const [],
    this.website,
    this.email,
    required this.description,
  });
}

final List<EmergencyContact> emergencyContacts = [
  EmergencyContact(
    title: "Sexual & Gender-Based Violence (SGBV) Support",
    contacts: [
      ContactDetail(
        name: "Women in Need (WIN) 24/7 Helpline",
        phones: ["011 471 8585"],
        website: "https://www.winsl.net",
        description:
            "Offers legal aid, counseling, shelter, and medical referrals.",
      ),
      ContactDetail(
        name: "National Child Protection Authority (NCPA)",
        phones: ["1929"],
        website: "http://www.childprotection.gov.lk",
        description:
            "For reporting child sexual abuse, exploitation, or unsafe situations.",
      ),
    ],
  ),
  EmergencyContact(
    title: "Mental Health Support",
    contacts: [
      ContactDetail(
        name: "CCCline 1333",
        phones: ["1333"],
        website: "https://1333.lk/",
        description:
            "Confidential emotional support for anyone in distress.",
      ),
      ContactDetail(
        name: "Sumithrayo",
        phones: ["011 269 6666", "011 269 2909", "011 268 3555"],
        email: "sumithra@sumithrayo.org",
        website: "https://sumithrayo.org/",
        description:
            "Offers support for emotional crises, suicidal thoughts, etc.",
      ),
    ],
  ),
  EmergencyContact(
    title: "Reproductive Health Services",
    contacts: [
      ContactDetail(
        name: "Family Planning Association of Sri Lanka (FPA)",
        phones: ["011 255 5455"],
        website: "https://www.fpasrilanka.org/",
        description:
            "Contraceptives, STI testing, counseling, and education.",
      ),
      ContactDetail(
        name: "National STD/AIDS Control Programme",
        phones: ["011 266 7029"],
        website: "http://www.aidscontrol.gov.lk",
        description: "Free STI/HIV testing & counseling.",
      ),
    ],
  ),
  EmergencyContact(
    title: "General Emergencies",
    contacts: [
      ContactDetail(
        name: "Ambulance Service (Suwa Seriya 1990)",
        phones: ["1990"],
        description:
            "For any medical emergency including sexual assault or mental health crises.",
      ),
      ContactDetail(
        name: "Police Emergency Line",
        phones: ["119"],
        description: "For immediate threats, including physical or sexual violence.",
      ),
      ContactDetail(
        name: "Fire & Rescue",
        phones: ["110"],
        description: "For fire emergencies, rescue operations, and disaster response assistance.",
      ),
    ],
  ),
];