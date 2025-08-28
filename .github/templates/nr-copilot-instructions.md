# Natural Resources Domain Repository - AI Coding Instructions

This repository follows BCGov AI coding standards with Natural Resources (NR) domain specific enhancements.

## Repository Context
This is a Natural Resources domain application handling sensitive environmental, forestry, or resource data. Data sovereignty, privacy, and regulatory compliance are critical.

## Natural Resources Domain Practices

### Data Sovereignty & Privacy
- All data processing must comply with BC data sovereignty requirements
- Sensitive location data requires special handling and access controls
- Follow BCGov privacy guidelines for environmental and resource data
- Consider Indigenous data sovereignty principles (OCAP - Ownership, Control, Access, Possession)
- Implement proper data classification and handling procedures

### Environmental Data Standards
- Use standardized environmental data formats and coordinate systems
- Follow established natural resources data schemas and validation rules
- Implement proper data quality checks for environmental measurements
- Support both metric and imperial units with clear conversion standards
- Handle temporal data correctly (seasons, migration patterns, etc.)

### Integration with NR Systems
- Design for integration with existing NR databases and systems
- Follow established NR API standards and authentication patterns
- Support common NR data exchange formats (GIS, scientific data formats)
- Consider offline/field usage scenarios with sync capabilities
- Plan for integration with mapping and geospatial systems

### Regulatory Compliance
- Ensure compliance with environmental reporting requirements
- Follow forestry management and conservation regulations
- Support audit trails for regulatory reporting
- Implement proper approval workflows for sensitive operations
- Consider requirements for public disclosure and transparency

### Field Operations Support
- Design interfaces suitable for field workers and researchers
- Support mobile/tablet usage in outdoor environments
- Handle unreliable network connectivity gracefully
- Provide offline capabilities where appropriate
- Consider rugged device compatibility and accessibility

### Scientific Data Quality
- Implement proper data validation for scientific measurements
- Support statistical analysis and research requirements
- Maintain data lineage and methodology documentation
- Follow scientific data management best practices
- Enable data export in research-friendly formats

### Natural Resources User Experience
- Use terminology familiar to NR professionals and scientists
- Provide helpful context for environmental and resource management decisions
- Support different user types (scientists, field workers, managers, public)
- Include helpful documentation for domain-specific features
- Consider multilingual requirements for public-facing applications

### Geographic Information Systems (GIS)
- Integrate properly with BC geographic data standards
- Support common GIS workflows and data formats
- Provide accurate mapping and spatial analysis capabilities
- Follow established coordinate system standards for BC
- Enable proper spatial query and analysis functions

## Example Environment Variables
Natural Resources applications often need:
- `NR_ENVIRONMENT` (dev/test/prod with specific NR considerations)
- `GIS_SERVICE_URL` (for mapping integration)
- `SCIENTIFIC_DATA_API` (for research data access)
- Database connections for NR-specific data sources

Remember: NR applications often serve both internal staff and the public - consider both audiences in design decisions.
