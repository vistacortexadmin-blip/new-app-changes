import '../../features/reports/models/report_model.dart';
import '../../features/reminders/models/reminder_model.dart';
import '../../features/recovery_care/models/recovery_model.dart';
import '../../features/family_connect/models/family_model.dart';
import '../../features/test_booking/models/test_booking_model.dart';

class SeedData {
  // 1. Initial Medical Reports with Parameters
  static List<MedicalReport> get initialReports => [
        MedicalReport(
          id: 'rep_001',
          title: 'Comprehensive Metabolic & Lipid Panel',
          category: ReportCategory.lipidProfile,
          labProvider: 'Apollo Diagnostic Specialty Labs',
          doctorName: 'Dr. Arvind Sharma, MD (Cardiology)',
          reportDate: DateTime.now().subtract(const Duration(days: 3)),
          pdfAssetPath: 'assets/documents/sample_report.pdf',
          summaryPlainLanguage:
              'Your total cholesterol and LDL (bad cholesterol) have decreased by 14% compared to last month following your statin routine. Fasting blood sugar is stable and within normal target range.',
          questionsForDoctor: [
            'Should I continue the current 20mg Atorvastatin dosage for another 3 months?',
            'Is the current diet adequate for maintaining the improved HDL cholesterol level?',
            'When should the next liver function panel be scheduled?'
          ],
          isFlagged: false,
          parameters: [
            TestParameter(
              id: 'param_01',
              name: 'Total Cholesterol',
              value: 178,
              unit: 'mg/dL',
              minNormal: 125,
              maxNormal: 200,
              interpretation: 'Optimal target range achieved.',
            ),
            TestParameter(
              id: 'param_02',
              name: 'LDL Cholesterol (Bad)',
              value: 94,
              unit: 'mg/dL',
              minNormal: 50,
              maxNormal: 100,
              interpretation: 'Well controlled with prescribed therapy.',
            ),
            TestParameter(
              id: 'param_03',
              name: 'HDL Cholesterol (Good)',
              value: 48,
              unit: 'mg/dL',
              minNormal: 40,
              maxNormal: 60,
              interpretation: 'Normal cardioprotective level.',
            ),
            TestParameter(
              id: 'param_04',
              name: 'Triglycerides',
              value: 135,
              unit: 'mg/dL',
              minNormal: 50,
              maxNormal: 150,
              interpretation: 'Normal baseline.',
            ),
            TestParameter(
              id: 'param_05',
              name: 'Fasting Blood Glucose',
              value: 92,
              unit: 'mg/dL',
              minNormal: 70,
              maxNormal: 99,
              interpretation: 'Normal fasting glycemic balance.',
            ),
          ],
        ),
        MedicalReport(
          id: 'rep_002',
          title: 'Complete Blood Count (CBC) & Ferritin',
          category: ReportCategory.bloodTest,
          labProvider: 'MaxCare Path Labs Ltd.',
          doctorName: 'Dr. Priya Desai, MD (Internal Medicine)',
          reportDate: DateTime.now().subtract(const Duration(days: 28)),
          pdfAssetPath: 'assets/documents/sample_report.pdf',
          summaryPlainLanguage:
              'Hemoglobin and platelet levels are healthy. White blood cell count indicates normal immune function with no signs of acute infection.',
          questionsForDoctor: [
            'Are my iron/ferritin reserves sufficient to discontinue iron supplements?',
            'Can I resume vigorous cardiovascular training?'
          ],
          isFlagged: false,
          parameters: [
            TestParameter(
              id: 'param_11',
              name: 'Hemoglobin',
              value: 14.2,
              unit: 'g/dL',
              minNormal: 13.0,
              maxNormal: 17.0,
              interpretation: 'Optimal oxygen-carrying capacity.',
            ),
            TestParameter(
              id: 'param_12',
              name: 'WBC (Total Leucocytes)',
              value: 6800,
              unit: '/mcL',
              minNormal: 4500,
              maxNormal: 11000,
              interpretation: 'Normal immune baseline.',
            ),
            TestParameter(
              id: 'param_13',
              name: 'Platelet Count',
              value: 245000,
              unit: '/mcL',
              minNormal: 150000,
              maxNormal: 450000,
              interpretation: 'Normal clotting capability.',
            ),
            TestParameter(
              id: 'param_14',
              name: 'Serum Ferritin',
              value: 68,
              unit: 'ng/mL',
              minNormal: 30,
              maxNormal: 300,
              interpretation: 'Iron stores replenished.',
            ),
          ],
        ),
        MedicalReport(
          id: 'rep_003',
          title: 'Glycated Hemoglobin (HbA1c) 3-Month Trend',
          category: ReportCategory.diabeticPanel,
          labProvider: 'Quest Diagnostic Center',
          doctorName: 'Dr. Rajiv Menon, Endocrinologist',
          reportDate: DateTime.now().subtract(const Duration(days: 65)),
          pdfAssetPath: 'assets/documents/sample_report.pdf',
          summaryPlainLanguage:
              'HbA1c level is 5.8%, reflecting stable glucose regulation over the prior 90-day period without hypoglycemic episodes.',
          questionsForDoctor: [
            'Do I need to check post-prandial glucose daily or weekly?',
          ],
          isFlagged: false,
          parameters: [
            TestParameter(
              id: 'param_21',
              name: 'HbA1c',
              value: 5.8,
              unit: '%',
              minNormal: 4.0,
              maxNormal: 5.6,
              interpretation: 'Prediabetes boundary; lifestyle controlled.',
            ),
            TestParameter(
              id: 'param_22',
              name: 'Estimated Avg Glucose (eAG)',
              value: 120,
              unit: 'mg/dL',
              minNormal: 90,
              maxNormal: 130,
              interpretation: 'Good long-term consistency.',
            ),
          ],
        ),
      ];

  // 2. Active Medicine Schedules & Refill Tracker
  static List<MedicineReminder> get initialReminders => [
        MedicineReminder(
          id: 'med_001',
          medicineName: 'Atorvastatin 20mg',
          dosage: '1 Tablet',
          instructions: 'Take at bedtime with water',
          prescribedFor: 'Lipid Management & Cardioprotection',
          totalQuantityAvailable: 18,
          dailyDoseCount: 1,
          startDate: DateTime.now().subtract(const Duration(days: 12)),
          durationDays: 30,
          dailySchedules: [
            DoseSchedule(
              timeOfDay: DoseTimeOfDay.night,
              timeString: '09:30 PM',
              status: AdherenceStatus.pending,
            ),
          ],
        ),
        MedicineReminder(
          id: 'med_002',
          medicineName: 'Metformin SR 500mg',
          dosage: '1 Tablet',
          instructions: 'Take with or immediately after meals',
          prescribedFor: 'Glycemic Regulation',
          totalQuantityAvailable: 6, // Low supply trigger!
          dailyDoseCount: 2,
          startDate: DateTime.now().subtract(const Duration(days: 24)),
          durationDays: 30,
          dailySchedules: [
            DoseSchedule(
              timeOfDay: DoseTimeOfDay.morning,
              timeString: '08:30 AM',
              status: AdherenceStatus.taken,
              loggedAt: DateTime.now().subtract(const Duration(hours: 3)),
            ),
            DoseSchedule(
              timeOfDay: DoseTimeOfDay.night,
              timeString: '08:30 PM',
              status: AdherenceStatus.pending,
            ),
          ],
        ),
        MedicineReminder(
          id: 'med_003',
          medicineName: 'Omega-3 CoQ10 Complex',
          dosage: '1 Capsule',
          instructions: 'Take with morning breakfast',
          prescribedFor: 'Cardiovascular Vitality & Joint Health',
          totalQuantityAvailable: 45,
          dailyDoseCount: 1,
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          durationDays: 60,
          dailySchedules: [
            DoseSchedule(
              timeOfDay: DoseTimeOfDay.morning,
              timeString: '09:00 AM',
              status: AdherenceStatus.taken,
              loggedAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ],
        ),
      ];

  // 3. Next Test Reminders
  static List<NextTestReminder> get initialNextTests => [
        NextTestReminder(
          id: 'next_001',
          testName: 'Follow-up Fasting Lipid Profile',
          labOrClinicName: 'Apollo Diagnostics - Central Branch',
          scheduledDate: DateTime.now().add(const Duration(days: 14)),
          preparationInstructions: '10-12 hours overnight fasting mandatory. Water permitted.',
          relatedReportId: 'rep_001',
        ),
        NextTestReminder(
          id: 'next_002',
          testName: 'Routine HbA1c & Kidney Function (KFT)',
          labOrClinicName: 'MaxCare Pathology',
          scheduledDate: DateTime.now().add(const Duration(days: 25)),
          preparationInstructions: 'No fasting required for HbA1c. Stay well hydrated.',
          relatedReportId: 'rep_003',
        ),
      ];

  // 4. Recovery Plan & Care Checklist
  static RecoveryCarePlan get initialRecoveryPlan => RecoveryCarePlan(
        id: 'recov_001',
        procedureName: 'Post-Op Knee Arthroscopy & Meniscal Care',
        operatingSurgeon: 'Dr. Anand Verma, Orthopedic Surgeon',
        hospitalName: 'Apollo Specialty Ortho Center',
        surgeryDate: DateTime.now().subtract(const Duration(days: 8)),
        totalRecoveryDays: 28,
        currentDay: 8,
        painLevelScore: 3,
        clinicalPrecautions: [
          'Keep surgical incision dressing clean and dry.',
          'Elevate leg for 20 minutes every 3-4 hours to reduce swelling.',
          'Avoid heavy weight-bearing or pivoting movements.',
          'Contact surgeon immediately if fever > 101°F or severe redness occurs.'
        ],
        todayTasks: [
          DailyCareTask(
            id: 'task_01',
            title: 'Morning Ice Compress (15 mins)',
            description: 'Apply wrapped cold pack over knee to soothe swelling.',
            timeOfDay: '08:00 AM',
            category: CareTaskCategory.restMilestone,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          DailyCareTask(
            id: 'task_02',
            title: 'Gentle Quad Sets & Ankle Pumps',
            description: 'Perform 3 sets of 10 repetitions without straining.',
            timeOfDay: '11:00 AM',
            category: CareTaskCategory.mobilityExercise,
            isCompleted: true,
            completedAt: DateTime.now().subtract(const Duration(minutes: 45)),
          ),
          DailyCareTask(
            id: 'task_03',
            title: 'Incision Site & Bandage Check',
            description: 'Inspect dressing edges for dryness and normal healing.',
            timeOfDay: '03:00 PM',
            category: CareTaskCategory.woundDressing,
            isCompleted: false,
          ),
          DailyCareTask(
            id: 'task_04',
            title: 'Evening Physical Therapy Assisted Walk',
            description: 'Use support crutch for a 10-minute indoor walk.',
            timeOfDay: '06:30 PM',
            category: CareTaskCategory.mobilityExercise,
            isCompleted: false,
          ),
        ],
      );

  // 5. Patient Diet Plan
  static PatientDietPlan get initialDietPlan => PatientDietPlan(
        planTitle: 'Anti-Inflammatory & Low Glycemic Nutrition Plan',
        conditionContext: 'Cardiovascular Support & Tissue Healing',
        generalGuidance:
            'Focus on whole colorful vegetables, lean proteins, high-fiber grains, and omega-rich fats. Limit refined sugars and sodium under 2000mg/day.',
        foodDrugInteractions: [
          'Avoid Grapefruit / Pomelo juice (interferes with Atorvastatin clearance).',
          'Maintain consistent intake of leafy greens without abrupt spikes.',
          'Space calcium/antacid supplements 2 hours apart from morning medication.'
        ],
        dailyMeals: [
          MealGuidance(
            mealType: 'Breakfast (08:00 - 09:00 AM)',
            recommendedFood: 'Steel-cut oats with chia seeds, crushed walnuts, blueberries, and boiled egg whites.',
            benefits: 'High soluble fiber to lower LDL cholesterol; steady energy release.',
            caloriesAndNutrients: '380 kcal · 18g Protein · 8g Fiber',
            avoidFoods: ['Sugary breakfast cereals', 'Bakery pastries', 'Processed sausage'],
          ),
          MealGuidance(
            mealType: 'Lunch (01:00 - 02:00 PM)',
            recommendedFood: 'Quinoa bowl with grilled chicken or steamed paneer, mixed greens, avocado, and olive oil vinaigrette.',
            benefits: 'High bio-available protein for post-surgical tissue repair.',
            caloriesAndNutrients: '520 kcal · 32g Protein · 12g Fiber',
            avoidFoods: ['Deep-fried fast food', 'High-sodium canned soups', 'White bread'],
          ),
          MealGuidance(
            mealType: 'Evening Snack (05:00 PM)',
            recommendedFood: 'Handful of roasted almonds + warm green tea or tender coconut water.',
            benefits: 'Magnesium and polyphenols supporting cardiovascular vessel elasticity.',
            caloriesAndNutrients: '160 kcal · 6g Protein · 4g Fiber',
            avoidFoods: ['Salted potato chips', 'Sugary sodas'],
          ),
          MealGuidance(
            mealType: 'Dinner (07:30 - 08:30 PM)',
            recommendedFood: 'Steamed vegetable stew with lentils (dal) and one multi-grain roti, light cucumber salad.',
            benefits: 'Light evening digestion, preventing night-time glycemic spikes.',
            caloriesAndNutrients: '410 kcal · 20g Protein · 9g Fiber',
            avoidFoods: ['Heavy cream curries', 'Late-night sugary desserts'],
          ),
        ],
      );

  // 6. Family Connect Members & Logs
  static List<FamilyMember> get initialFamilyMembers => [
        FamilyMember(
          id: 'fam_01',
          fullName: 'Ananya Sharma',
          relationship: 'Spouse & Primary Caregiver',
          phoneNumber: '+91 98765 43210',
          email: 'ananya.sharma@example.com',
          permission: FamilyPermissionLevel.fullCareSupport,
          invitedAt: DateTime.now().subtract(const Duration(days: 60)),
          alertOnMissedMedicine: true,
          avatarInitials: 'AS',
        ),
        FamilyMember(
          id: 'fam_02',
          fullName: 'Rohan Sharma',
          relationship: 'Son',
          phoneNumber: '+91 98123 45678',
          email: 'rohan.sharma@example.com',
          permission: FamilyPermissionLevel.reminderOnly,
          invitedAt: DateTime.now().subtract(const Duration(days: 15)),
          alertOnMissedMedicine: false,
          avatarInitials: 'RS',
        ),
      ];

  static List<SharedActivityLog> get initialActivityLogs => [
        SharedActivityLog(
          id: 'log_01',
          memberName: 'Ananya Sharma',
          actionDescription: 'Viewed latest Metabolic & Lipid Report',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        SharedActivityLog(
          id: 'log_02',
          memberName: 'System Alert',
          actionDescription: 'Shared reminder for Metformin morning dose',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ];

  // 7. Diagnostic Test Providers & Bookable Catalog
  static List<DiagnosticProvider> get diagnosticProviders => [
        DiagnosticProvider(
          id: 'prov_01',
          name: 'Apollo Diagnostics Excellence Center',
          address: 'Sector 14, Main Medical Corridor',
          rating: 4.9,
          totalReviews: 840,
          distanceKm: 1.8,
          accreditedBy: 'NABL & CAP Certified',
          contactPhone: '+91 80 2222 3333',
        ),
        DiagnosticProvider(
          id: 'prov_02',
          name: 'MaxCare Pathology & Imaging Hub',
          address: 'Green Park, Block C, Healthcare Plaza',
          rating: 4.8,
          totalReviews: 610,
          distanceKm: 3.2,
          accreditedBy: 'NABL & ISO 15189 Certified',
          contactPhone: '+91 80 4444 5555',
        ),
        DiagnosticProvider(
          id: 'prov_03',
          name: 'MedAll Clinical & Radiology Labs',
          address: '4th Avenue, Indiranagar',
          rating: 4.7,
          totalReviews: 430,
          distanceKm: 4.5,
          accreditedBy: 'NABL Certified',
          contactPhone: '+91 80 6666 7777',
        ),
      ];

  static List<BookableTest> get bookableTests => [
        BookableTest(
          id: 'test_01',
          name: 'Comprehensive Health & Lipid Profile',
          category: 'Blood & Metabolic',
          description: '65 vital parameters including Complete Blood Count, Lipid Panel, Liver & Kidney profiles.',
          preparationInstruction: '10-12 hours fasting required. Morning sample collection.',
          price: 1299.0,
          reportDeliveryTime: 'Within 12 Hours',
          includedParameters: [
            'Cholesterol Total & Fractions',
            'Fasting Blood Sugar',
            'Liver Enzymes (SGOT/SGPT)',
            'Serum Creatinine & Urea',
            'Hemogram CBC 24 Parameters'
          ],
        ),
        BookableTest(
          id: 'test_02',
          name: 'Glycated Hemoglobin (HbA1c) Test',
          category: 'Diabetic Health',
          description: 'Gold-standard test measuring 3-month average blood glucose regulation.',
          preparationInstruction: 'No fasting required. Any time of day.',
          price: 450.0,
          reportDeliveryTime: 'Within 6 Hours',
          includedParameters: ['HbA1c %', 'Estimated Average Glucose (eAG)'],
        ),
        BookableTest(
          id: 'test_03',
          name: 'Thyroid Function Ultra Panel (T3, T4, TSH)',
          category: 'Endocrinology',
          description: 'Measures total & free thyroid hormone balance for metabolic and energy health.',
          preparationInstruction: 'Morning sample preferred before taking thyroid medication.',
          price: 650.0,
          reportDeliveryTime: 'Same Day (8 Hours)',
          includedParameters: ['Total T3', 'Total T4', 'Ultrasensitive TSH'],
        ),
        BookableTest(
          id: 'test_04',
          name: 'Vitamin D3 & Vitamin B12 Duo',
          category: 'Vital Vitamins',
          description: 'Essential bone, nerve, and energy metabolism vitamin level evaluation.',
          preparationInstruction: 'No special preparation needed.',
          price: 999.0,
          reportDeliveryTime: 'Within 24 Hours',
          includedParameters: ['25-Hydroxy Vitamin D', 'Active Vitamin B12'],
        ),
      ];
}
