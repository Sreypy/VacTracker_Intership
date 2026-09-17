import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { VaccineLibrary } from './entities/vaccine-library.entity';

@Injectable()
export class VaccineLibrarySeeder implements OnModuleInit {
  private readonly logger = new Logger(VaccineLibrarySeeder.name);

  constructor(
    @InjectRepository(VaccineLibrary)
    private readonly libraryRepository: Repository<VaccineLibrary>,
  ) {}

  async onModuleInit() {
    await this.seed();
  }

  private async seed() {
    const count = await this.libraryRepository.count();

    if (count > 0) {
      this.logger.log('Vaccine library already has data. Skipping seed.');
      return;
    }

    const articles: Partial<VaccineLibrary>[] = [
      // 1. Newcastle Vaccine
      {
        name_en: 'Newcastle Vaccine',
        name_km: 'វ៉ាក់សាំងញូវកាសល',
        disease_en: 'Newcastle Disease',
        disease_km: 'ជំងឺញូវកាសល',
        description_en:
            'A vaccine that helps protect chickens from Newcastle disease, a serious viral disease that can spread quickly among poultry.',
        description_km:
            'វ៉ាក់សាំងដែលជួយការពារមាន់ពីជំងឺញូវកាសល ដែលជាជំងឺមេរោគធ្ងន់ធ្ងរអាចរាលដាលយ៉ាងលឿនក្នុងចំណោមបសុបក្សី។',
        disease_description_en:
            'Newcastle disease is a highly contagious viral disease that affects chickens and other birds. It can cause breathing problems, diarrhea, and sudden death. Sick birds may also show twisting of the neck and not want to eat. The disease can spread very quickly between flocks and cause large losses.',
        disease_description_km:
            'ជំងឺញូវកាសល គឺជាជំងឺមេរោគឆ្លងខ្លាំងដែលប៉ះពាល់ដល់មាន់ និងបក្សីដទៃទៀត។ វាអាចបណ្តាលឱ្យមានបញ្ហាដកដង្ហើម រាគ និងស្លាប់ភ្លាមៗ។ មាន់ឈឺអាចបង្ហាញការរមួលក និងមិនព្រមស៊ី។ ជំងឺនេះអាចរាលដាលយ៉ាងលឿនរវាងហ្វូង និងបណ្តាលឱ្យខូចខាតធំ។',
        why_important_en:
            'Newcastle disease is one of the most dangerous diseases for chickens in Cambodia. Vaccination helps protect your flock from serious illness and death, and helps prevent the disease from spreading to other farms.',
        why_important_km:
            'ជំងឺញូវកាសល គឺជាជំងឺមួយក្នុងចំណោមជំងឺគ្រោះថ្នាក់បំផុតសម្រាប់មាន់នៅកម្ពុជា។ ការចាក់វ៉ាក់សាំងជួយការពារហ្វូងមាន់របស់អ្នកពីជំងឺធ្ងន់ធ្ងរ និងការស្លាប់ ហើយជួយការពារកុំឱ្យជំងឺរាលដាលទៅកសិដ្ឋានផ្សេងទៀត។',
        usage_en:
            'Newcastle vaccine is usually given to healthy chickens. The method depends on the specific vaccine product — it may be given as eye drops, drinking water, or spray. Always follow the instructions on the vaccine product label and ask your local animal-health advisor for guidance on the right age and method for your chickens.',
        usage_km:
            'វ៉ាក់សាំងញូវកាសល ជាធម្មតាចាក់ឱ្យមាន់ដែលមានសុខភាពល្អ។ វិធីសាស្ត្រអាស្រ័យលើប្រភេទវ៉ាក់សាំង — អាចបន្តក់ភ្នែក លាយទឹកផឹក ឬបាញ់។ តែងតែអនុវត្តតាមការណែនាំនៅលើស្លាកផលិតផលវ៉ាក់សាំង និងសួរអ្នកជំនាញសុខភាពសត្វក្នុងតំបន់របស់អ្នកសម្រាប់ការណែនាំអំពីអាយុ និងវិធីសាស្ត្រត្រឹមត្រូវ។',
        precautions_en:
            'Only vaccinate healthy chickens. Do not use the vaccine if it has expired or if the bottle is damaged. Keep the vaccine cold as instructed on the label. Handle live vaccines carefully and wash your hands after use. Do not throw vaccine containers where birds or children can reach them. If chickens are already sick, contact your animal-health advisor before vaccinating.',
        precautions_km:
            'ចាក់វ៉ាក់សាំងតែចំពោះមាន់ដែលមានសុខភាពល្អប៉ុណ្ណោះ។ កុំប្រើវ៉ាក់សាំងដែលផុតកំណត់ ឬដបខូច។ ទុកវ៉ាក់សាំងឱ្យត្រជាក់តាមការណែនាំនៅលើស្លាក។ ប្រុងប្រយ័ត្នពេលប្រើវ៉ាក់សាំងមានជីវិត និងលាងដៃក្រោយប្រើ។ កុំបោះចោលធុងវ៉ាក់សាំងកន្លែងដែលបក្សី ឬកុមារអាចទៅដល់។ ប្រសិនបើមាន់ឈឺរួចហើយ សូមទាក់ទងអ្នកជំនាញសុខភាពសត្វមុនពេលចាក់វ៉ាក់សាំង។',
        other_info_en:
            'Newcastle disease can appear in different forms, from mild to very severe. Some birds may die without showing any signs. Even vaccinated flocks should be observed carefully and reported to local authorities if signs of disease appear. Good farm hygiene and stopping new birds from entering without quarantine also help prevent disease.',
        other_info_km:
            'ជំងឺញូវកាសលអាចមានទម្រង់ផ្សេងៗ ពីស្រាលទៅធ្ងន់ធ្ងរ។ បក្សីខ្លះអាចស្លាប់ដោយមិនបង្ហាញសញ្ញាអ្វីទាល់តែសោះ។ សូម្បីតែហ្វូងដែលបានចាក់វ៉ាក់សាំងរួច គួរតែតាមដានដោយប្រុងប្រយ័ត្ន និងរាយការណ៍ទៅអាជ្ញាធរមូលដ្ឋាន ប្រសិនបើឃើញសញ្ញាជំងឺ។ អនាម័យកសិដ្ឋានល្អ និងការមិនឱ្យមាន់ថ្មីចូលដោយគ្មានការឃ្លាំមើលក៏ជួយការពារជំងឺផងដែរ។',
        category: 'core',
      },

      // 2. Gumboro Vaccine
      {
        name_en: 'Gumboro Vaccine',
        name_km: 'វ៉ាក់សាំងហ្គាំបូរ៉ូ',
        disease_en: 'Gumboro Disease (Infectious Bursal Disease)',
        disease_km: 'ជំងឺហ្គាំបូរ៉ូ (ជំងឺរលាកបឺស)',
        description_en:
            'A vaccine that helps protect young chickens from Gumboro disease, which weakens the immune system and makes birds more likely to get other diseases.',
        description_km:
            'វ៉ាក់សាំងដែលជួយការពារមាន់វ័យក្មេងពីជំងឺហ្គាំបូរ៉ូ ដែលធ្វើឱ្យប្រព័ន្ធការពាររាងកាយចុះខ្សោយ និងធ្វើឱ្យបក្សីងាយកើតជំងឺផ្សេងទៀត។',
        disease_description_en:
            'Gumboro disease is a viral disease that mainly affects young chickens. It attacks the immune system, making chickens weaker and more likely to catch other diseases. Sick chickens may lose appetite, have ruffled feathers, appear depressed, and may have diarrhea. Some chickens may die, while others may recover but stay weaker.',
        disease_description_km:
            'ជំងឺហ្គាំបូរ៉ូ គឺជាជំងឺមេរោគដែលប៉ះពាល់ជាចម្បងដល់មាន់វ័យក្មេង។ វាវាយប្រហារប្រព័ន្ធការពាររាងកាយ ធ្វើឱ្យមាន់ចុះខ្សោយ និងងាយកើតជំងឺផ្សេងទៀត។ មាន់ឈឺអាចបាត់បង់ចំណង់អាហារ រោមរញ៉េរញ៉ៃ មើលទៅមិនស្វាហាប់ និងអាចរាគ។ មាន់ខ្លះអាចស្លាប់ ខណៈខ្លះទៀតអាចជាសះស្បើយ ប៉ុន្តែនៅតែចុះខ្សោយ។',
        why_important_en:
            'Gumboro disease is dangerous because it weakens the chicken immune system. Vaccinating young chickens helps protect them during the vulnerable early period when they are most at risk, and reduces losses on the farm.',
        why_important_km:
            'ជំងឺហ្គាំបូរ៉ូមានគ្រោះថ្នាក់ព្រោះវាធ្វើឱ្យប្រព័ន្ធការពាររាងកាយរបស់មាន់ចុះខ្សោយ។ ការចាក់វ៉ាក់សាំងដល់មាន់វ័យក្មេងជួយការពារពួកវាអំឡុងពេលងាយរងគ្រោះដំបូង និងកាត់បន្ថយការខូចខាតនៅលើកសិដ្ឋាន។',
        usage_en:
            'Gumboro vaccine is usually given to young chickens, and is often administered through drinking water or eye drops. The right age to vaccinate can vary depending on the product and the farm situation. Always follow the instructions on the vaccine product label and consult your local animal-health advisor.',
        usage_km:
            'វ៉ាក់សាំងហ្គាំបូរ៉ូ ជាធម្មតាចាក់ឱ្យមាន់វ័យក្មេង ហើយច្រើនលាយទឹកផឹក ឬបន្តក់ភ្នែក។ អាយុត្រឹមត្រូវសម្រាប់ការចាក់អាចខុសគ្នាអាស្រ័យលើផលិតផល និងស្ថានភាពកសិដ្ឋាន។ តែងតែអនុវត្តតាមការណែនាំនៅលើស្លាកផលិតផលវ៉ាក់សាំង និងពិគ្រោះជាមួយអ្នកជំនាញសុខភាពសត្វក្នុងតំបន់របស់អ្នក។',
        precautions_en:
            'Vaccinate only healthy chickens. Follow the correct storage and mixing instructions on the label. If using drinking water, make sure the water is clean and free of disinfectants. Give fresh vaccine solution and do not leave it in the sun. Contact your animal-health advisor if you have questions about timing.',
        precautions_km:
            'ចាក់វ៉ាក់សាំងតែចំពោះមាន់ដែលមានសុខភាពល្អប៉ុណ្ណោះ។ អនុវត្តតាមការណែនាំអំពីការទុកដាក់ និងលាយត្រឹមត្រូវនៅលើស្លាក។ ប្រសិនបើលាយទឹកផឹក ត្រូវប្រាកដថាទឹកស្អាត និងគ្មានថ្នាំសម្លាប់មេរោគ។ ឱ្យទឹកវ៉ាក់សាំងថ្មី ហើយកុំទុកក្រោមពន្លឺថ្ងៃ។ ទាក់ទងអ្នកជំនាញសុខភាពសត្វ ប្រសិនបើអ្នកមានសំណួរអំពីពេលវេលាចាក់។',
        other_info_en:
            'Gumboro disease is also called Infectious Bursal Disease (IBD). Since it weakens the immune system, chickens that survive the disease may be more at risk from other infections later. Clean housing, good litter management, and preventing contact with birds from other farms help reduce the spread of the disease.',
        other_info_km:
            'ជំងឺហ្គាំបូរ៉ូ ត្រូវបានគេហៅផងដែរថា ជំងឺរលាកបឺសឆ្លង (IBD)។ ដោយសារវាធ្វើឱ្យប្រព័ន្ធការពារចុះខ្សោយ មាន់ដែលរស់រានពីជំងឺនេះអាចប្រឈមនឹងការឆ្លងផ្សេងៗនៅពេលក្រោយ។ ការសម្អាតទ្រុង ការគ្រប់គ្រងសំរាមល្អ និងការការពារកុំឱ្យបក្សីពីកសិដ្ឋានផ្សេងប៉ះពាល់ ជួយកាត់បន្ថយការរីករាលដាលនៃជំងឺ។',
        category: 'core',
      },

      // 3. Marek Vaccine
      {
        name_en: 'Marek Vaccine',
        name_km: 'វ៉ាក់សាំងម៉ារេក',
        disease_en: 'Marek Disease',
        disease_km: 'ជំងឺម៉ារេក',
        description_en:
            'A vaccine that helps protect chickens from Marek disease, a viral disease that can cause tumors, paralysis, and death.',
        description_km:
            'វ៉ាក់សាំងដែលជួយការពារមាន់ពីជំងឺម៉ារេក ដែលជាជំងឺមេរោគអាចបណ្តាលឱ្យមានដុំសាច់ ខ្វិន និងស្លាប់។',
        disease_description_en:
            'Marek disease is a viral disease caused by a herpes virus. It spreads easily between chickens, often through feather dust in the poultry house. Infected chickens may show paralysis, weight loss, tumors, or changes in the eyes. The disease can cause serious losses in young flocks.',
        disease_description_km:
            'ជំងឺម៉ារេក គឺជាជំងឺមេរោគបង្កឡើងដោយមេរោគហឺប៉េស។ វាឆ្លងយ៉ាងងាយរវាងមាន់ ច្រើនតាមរយៈធូលីរោមក្នុងទ្រុងមាន់។ មាន់ដែលឆ្លងអាចបង្ហាញការខ្វិន ស្រកទម្ងន់ ដុំសាច់ ឬការប្រែប្រួលភ្នែក។ ជំងឺនេះអាចបណ្តាលឱ្យខូចខាតធ្ងន់ធ្ងរនៅក្នុងហ្វូងវ័យក្មេង។',
        why_important_en:
            'Marek disease is very common in poultry environments and difficult to control once it spreads. Vaccinating chicks at a young age helps protect them from this disease and reduces the risk of large losses in the flock.',
        why_important_km:
            'ជំងឺម៉ារេកជារឿងធម្មតាក្នុងបរិស្ថានបសុបក្សី ហើយពិបាកគ្រប់គ្រងនៅពេលដែលវារាលដាល។ ការចាក់វ៉ាក់សាំងដល់កូនមាន់តាំងពីវ័យក្មេងជួយការពារពួកវាពីជំងឺនេះ និងកាត់បន្ថយហានិភ័យនៃការខូចខាតធំនៅក្នុងហ្វូង។',
        usage_en:
            'Marek vaccine is usually given to chicks when they are very young, often at the hatchery. The method and timing depend on the specific vaccine product. Always follow the instructions on the vaccine product label and consult your local animal-health advisor.',
        usage_km:
            'វ៉ាក់សាំងម៉ារេក ជាធម្មតាចាក់ឱ្យកូនមាន់តាំងពីតូច ច្រើននៅរោងភ្ញាស់។ វិធីសាស្ត្រ និងពេលវេលាអាស្រ័យលើប្រភេទផលិតផលវ៉ាក់សាំង។ តែងតែអនុវត្តតាមការណែនាំនៅលើស្លាកផលិតផលវ៉ាក់សាំង និងពិគ្រោះជាមួយអ្នកជំនាញសុខភាពសត្វក្នុងតំបន់របស់អ្នក។',
        precautions_en:
            'Marek vaccine is usually given to very young chicks according to the product instructions. Keep the vaccine cold as required. Do not expose the diluted vaccine to sunlight or heat. Only open the vaccine when you are ready to use it. Follow good hygiene practices in the poultry house.',
        precautions_km:
            'វ៉ាក់សាំងម៉ារេក ជាធម្មតាចាក់ឱ្យកូនមាន់តូចតាមការណែនាំផលិតផល។ ទុកវ៉ាក់សាំងឱ្យត្រជាក់តាមតម្រូវការ។ កុំឱ្យវ៉ាក់សាំងដែលលាយរួចប៉ះនឹងពន្លឺថ្ងៃ ឬកម្តៅ។ បើកវ៉ាក់សាំងតែពេលត្រៀមប្រើប៉ុណ្ណោះ។ អនុវត្តអនាម័យល្អនៅក្នុងទ្រុងមាន់។',
        other_info_en:
            'Marek disease virus can stay in the poultry house for a long time, so good cleaning between flocks is important. The vaccine protects against disease but may not stop the virus from spreading between birds. Buy chicks from reliable hatcheries and keep good biosecurity on your farm.',
        other_info_km:
            'មេរោគជំងឺម៉ារេកអាចស្ថិតក្នុងទ្រុងមាន់បានរយៈពេលយូរ ដូច្នេះការសម្អាតល្អរវាងហ្វូងនីមួយៗគឺសំខាន់។ វ៉ាក់សាំងការពារពីជំងឺ ប៉ុន្តែអាចមិនបញ្ឈប់ការរាលដាលរវាងបក្សី។ ទិញកូនមាន់ពីរោងភ្ញាស់ដែលអាចទុកចិត្តបាន និងរក្សាសន្តិសុខជីវសាស្ត្រល្អនៅលើកសិដ្ឋានរបស់អ្នក។',
        category: 'core',
      },

      // 4. Avian Influenza Vaccine
      {
        name_en: 'Avian Influenza Vaccine',
        name_km: 'វ៉ាក់សាំងផ្តាសាយបក្សី',
        disease_en: 'Avian Influenza (Bird Flu)',
        disease_km: 'ជំងឺផ្តាសាយបក្សី',
        description_en:
            'A vaccine that helps protect poultry from avian influenza, a serious viral disease that can cause severe illness and high death rates in birds.',
        description_km:
            'វ៉ាក់សាំងដែលជួយការពារបសុបក្សីពីជំងឺផ្តាសាយបក្សី ដែលជាជំងឺមេរោគធ្ងន់ធ្ងរអាចបណ្តាលឱ្យឈឺធ្ងន់ និងអត្រាស្លាប់ខ្ពស់នៅក្នុងបក្សី។',
        disease_description_en:
            'Avian influenza, also called bird flu, is a viral disease that can affect chickens, ducks, and other birds. Some forms of the virus cause only mild illness, while others can cause sudden death, severe breathing problems, swelling of the head, and a big drop in egg production. The disease can spread quickly between farms.',
        disease_description_km:
            'ជំងឺផ្តាសាយបក្សី គឺជាជំងឺមេរោគដែលអាចប៉ះពាល់ដល់មាន់ ទា និងបក្សីដទៃទៀត។ ទម្រង់ខ្លះនៃមេរោគបង្កឱ្យមានជំងឺស្រាល ខណៈខ្លះទៀតអាចបណ្តាលឱ្យស្លាប់ភ្លាមៗ បញ្ហាដកដង្ហើមធ្ងន់ធ្ងរ ហើមក្បាល និងការធ្លាក់ចុះយ៉ាងខ្លាំងនៃការពង។ ជំងឺនេះអាចរាលដាលយ៉ាងលឿនរវាងកសិដ្ឋាន។',
        why_important_en:
            'Avian influenza can cause very serious losses and can spread quickly between farms. Vaccination is one part of protecting your birds, along with good biosecurity, cleaning, and watching birds carefully for signs of disease. In Cambodia, avian influenza is also a disease that must be reported to animal-health authorities.',
        why_important_km:
            'ជំងឺផ្តាសាយបក្សីអាចបណ្តាលឱ្យខូចខាតធ្ងន់ធ្ងរ និងរាលដាលយ៉ាងលឿនរវាងកសិដ្ឋាន។ ការចាក់វ៉ាក់សាំងគឺជាផ្នែកមួយនៃការការពារបក្សីរបស់អ្នក រួមជាមួយសន្តិសុខជីវសាស្ត្រល្អ ការសម្អាត និងការតាមដានបក្សីដោយប្រុងប្រយ័ត្នសម្រាប់សញ្ញាជំងឺ។ នៅកម្ពុជា ជំងឺផ្តាសាយបក្សីគឺជាជំងឺដែលត្រូវតែរាយការណ៍ទៅអាជ្ញាធរសុខភាពសត្វ។',
        usage_en:
            'Avian influenza vaccine is used according to official animal-health recommendations. The method — injection, drinking water, or spray — depends on the specific vaccine product and the local disease situation. Always follow the instructions on the vaccine product label and the guidance of your local animal-health authorities.',
        usage_km:
            'វ៉ាក់សាំងផ្តាសាយបក្សីត្រូវប្រើតាមអនុសាសន៍របស់អាជ្ញាធរសុខភាពសត្វផ្លូវការ។ វិធីសាស្ត្រ — ចាក់ លាយទឹកផឹក ឬបាញ់ — អាស្រ័យលើប្រភេទផលិតផលវ៉ាក់សាំង និងស្ថានភាពជំងឺក្នុងតំបន់។ តែងតែអនុវត្តតាមការណែនាំនៅលើស្លាកផលិតផលវ៉ាក់សាំង និងការណែនាំរបស់អាជ្ញាធរសុខភាពសត្វក្នុងតំបន់របស់អ្នក។',
        precautions_en:
            'Avian influenza is a reportable disease. If you suspect your birds have avian influenza, contact your local animal-health authorities immediately — do not wait. Follow official guidance on vaccine use and movement of birds. Practice good biosecurity: limit visitors, clean equipment, and do not share tools with other farms.',
        precautions_km:
            'ជំងឺផ្តាសាយបក្សីគឺជាជំងឺដែលត្រូវរាយការណ៍។ ប្រសិនបើអ្នកសង្ស័យថាបក្សីរបស់អ្នកមានជំងឺផ្តាសាយបក្សី សូមទាក់ទងអាជ្ញាធរសុខភាពសត្វក្នុងតំបន់ភ្លាមៗ — កុំរង់ចាំ។ អនុវត្តតាមការណែនាំផ្លូវការអំពីការប្រើប្រាស់វ៉ាក់សាំង និងចលនាបក្សី។ អនុវត្តសន្តិសុខជីវសាស្ត្រល្អ៖ កំណត់អ្នកចូលទស្សនា សម្អាតឧបករណ៍ និងកុំចែករំលែកឧបករណ៍ជាមួយកសិដ្ឋានផ្សេង។',
        other_info_en:
            'Avian influenza viruses can change over time. Vaccination programmes for avian influenza are usually managed with the guidance of official animal-health programmes. Even when birds are vaccinated, signs of disease should be reported immediately, because vaccination does not completely remove the risk of infection or spread. Good biosecurity is the most important daily protection.',
        other_info_km:
            'មេរោគផ្តាសាយបក្សីអាចផ្លាស់ប្តូរតាមពេលវេលា។ កម្មវិធីចាក់វ៉ាក់សាំងផ្តាសាយបក្សី ជាធម្មតាត្រូវគ្រប់គ្រងដោយការណែនាំរបស់កម្មវិធីសុខភាពសត្វផ្លូវការ។ ទោះបីជាបក្សីត្រូវបានចាក់វ៉ាក់សាំងហើយក៏ដោយ សញ្ញានៃជំងឺគួរតែត្រូវបានរាយការណ៍ភ្លាមៗ ព្រោះការចាក់វ៉ាក់សាំងមិនបំបាត់ហានិភ័យនៃការឆ្លង ឬការរាលដាលទាំងស្រុងនោះទេ។ សន្តិសុខជីវសាស្ត្រល្អគឺជាការការពារប្រចាំថ្ងៃដ៏សំខាន់បំផុត។',
        category: 'reportable',
      },
    ];

    try {
      await this.libraryRepository.save(
        articles.map((article) =>
          this.libraryRepository.create(article),
        ),
      );
      this.logger.log(`Seeded ${articles.length} vaccine library articles.`);
    } catch (error) {
      this.logger.error('Failed to seed vaccine library.', error);
    }
  }
}