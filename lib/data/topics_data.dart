import 'package:aware_plus/data/module_data.dart';
import 'package:aware_plus/models/subtopic.dart';
import 'package:aware_plus/models/topic.dart';
import 'package:aware_plus/views/learning_module_view.dart';
import 'package:flutter/material.dart';

final List<Topic> topics = [
  Topic(
    title: 'Sexual and Reproductive Health Education',
    description:
        'Foundational knowledge about sexual health, healthy relationships, communication, and making informed decisions about your well-being.',
    subtopics: [
      Subtopic(
        title: 'What is sexual and reproductive health?',
        description:
            'Understanding the basics of sexual and reproductive health',
        onStart: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ModuleView(
                    topicId: "Sexual and Reproductive Health Education",
                    learningModels: srhLearningModels,
                    subtopicId: "What is sexual and reproductive health?",
                  ),
            ),
          );
        },
      ),
      Subtopic(
        title: 'Why is it important?',
        description: 'The importance for individuals and communities',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Healthy relationships: communication, respect, boundaries',
        description: 'Building and maintaining healthy relationships',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Emotional aspects of sexuality',
        description: 'Understanding attraction, love, and intimacy',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Making informed decisions about sexual health',
        description: 'Tools and strategies for decision-making',
        onStart: (context) {},
      ),
    ],
  ),
  Topic(
    title: 'Physical Sexual Health',
    description:
        'Understanding your body, maintaining physical well-being, and learning about reproductive anatomy, contraception, and health maintenance.',
    subtopics: [
      Subtopic(
        title: 'Male & female reproductive anatomy',
        description: 'Comprehensive overview of reproductive systems',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Puberty and body changes',
        description: 'Physical and emotional changes during puberty',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Menstrual cycle and health',
        description: 'Understanding menstruation and cycle health',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Contraception methods',
        description: 'Overview of pregnancy prevention methods',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'STI prevention and treatment',
        description: 'Sexually transmitted infections: prevention and care',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Personal hygiene and care',
        description: 'Maintaining genital health and hygiene',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Fertility and reproductive issues',
        description: 'Understanding PCOS, infertility, and other issues',
        onStart: (context) {},
      ),
    ],
  ),
  Topic(
    title: 'Rights, Laws & Ethics',
    description:
        'Empowering you to understand your rights, responsibilities, and the legal framework surrounding sexual and reproductive health.',
    subtopics: [
      Subtopic(
        title: 'Understanding consent',
        description: 'What consent means and why it\'s important',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Age of consent laws',
        description: 'Legal framework around age of consent',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Sexual harassment and assault laws',
        description: 'Understanding legal protections and rights',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Right to privacy in health',
        description: 'Your privacy rights in healthcare settings',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Access to safe healthcare',
        description: 'Understanding your right to safe, legal healthcare',
        onStart: (context) {},
      ),
    ],
  ),
  Topic(
    title: 'Myths & Misconceptions',
    description:
        'Debunking common false beliefs with evidence-based facts about sexual health, contraception, and reproductive wellness.',
    subtopics: [
      Subtopic(
        title: 'Pregnancy myths',
        description: 'Debunking common pregnancy misconceptions',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'STI misconceptions',
        description: 'Facts vs. fiction about sexually transmitted infections',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Myths about sexual activity',
        description: 'Separating fact from fiction about sexual health',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Cultural misconceptions',
        description: 'Addressing cultural myths with sensitivity',
        onStart: (context) {},
      ),
      Subtopic(
        title: 'Contraceptive myths',
        description: 'The truth about contraceptive effectiveness',
        onStart: (context) {},
      ),
    ],
  ),
];
